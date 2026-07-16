#!/usr/bin/env node

import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { extname, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = fileURLToPath(new URL(".", import.meta.url));
const repositoryRoot = resolve(scriptDirectory, "../..");
const marketingRoot = join(repositoryRoot, "marketing");
const contractPath = join(marketingRoot, "data/schemas/csv-contracts.json");

const failures = [];
const notices = [];
const counters = {
  csvContracts: 0,
  csvRows: 0,
  jsonFiles: 0,
  jsonlRows: 0,
  experimentPlans: 0,
  creativeRows: 0,
  driveSnapshots: 0,
};

function fail(message) {
  failures.push(message);
}

function notice(message) {
  notices.push(message);
}

function repoPath(absolutePath) {
  return relative(repositoryRoot, absolutePath).split(sep).join("/");
}

function walk(directory) {
  const output = [];
  if (!existsSync(directory)) return output;
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const absolutePath = join(directory, entry.name);
    if (entry.isDirectory()) output.push(...walk(absolutePath));
    else if (entry.isFile()) output.push(absolutePath);
  }
  return output;
}

function parseCsv(text, label) {
  const rows = [];
  let row = [];
  let field = "";
  let quoted = false;
  let quoteClosed = false;

  const pushField = () => {
    row.push(field);
    field = "";
    quoteClosed = false;
  };

  const pushRow = () => {
    pushField();
    rows.push(row);
    row = [];
  };

  const source = text.replace(/^\uFEFF/, "");
  for (let index = 0; index < source.length; index += 1) {
    const character = source[index];

    if (quoted) {
      if (character === '"') {
        if (source[index + 1] === '"') {
          field += '"';
          index += 1;
        } else {
          quoted = false;
          quoteClosed = true;
        }
      } else {
        field += character;
      }
      continue;
    }

    if (quoteClosed && character !== "," && character !== "\n" && character !== "\r") {
      throw new Error(`${label}: unexpected character after a closing quote`);
    }
    if (character === '"') {
      if (field.length > 0) throw new Error(`${label}: quote begins inside an unquoted field`);
      quoted = true;
    } else if (character === ",") {
      pushField();
    } else if (character === "\n") {
      pushRow();
    } else if (character === "\r") {
      if (source[index + 1] === "\n") index += 1;
      pushRow();
    } else {
      field += character;
    }
  }

  if (quoted) throw new Error(`${label}: unterminated quoted field`);
  if (field.length > 0 || row.length > 0 || quoteClosed) pushRow();
  while (rows.length > 1 && rows.at(-1).every((value) => value === "")) rows.pop();
  return rows;
}

function readCsv(absolutePath) {
  const label = repoPath(absolutePath);
  if (!existsSync(absolutePath)) {
    fail(`${label}: file is missing`);
    return { header: [], rows: [] };
  }
  try {
    const parsed = parseCsv(readFileSync(absolutePath, "utf8"), label);
    if (parsed.length === 0 || parsed[0].every((value) => value === "")) {
      fail(`${label}: CSV has no header`);
      return { header: [], rows: [] };
    }
    const header = parsed[0];
    const rows = [];
    for (let index = 1; index < parsed.length; index += 1) {
      const values = parsed[index];
      if (values.every((value) => value === "")) continue;
      if (values.length !== header.length) {
        fail(`${label}:${index + 1}: expected ${header.length} columns, found ${values.length}`);
        continue;
      }
      rows.push(Object.fromEntries(header.map((column, columnIndex) => [column, values[columnIndex]])));
    }
    return { header, rows };
  } catch (error) {
    fail(error.message);
    return { header: [], rows: [] };
  }
}

function arraysEqual(left, right) {
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

function isValidDate(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const [year, month, day] = value.split("-").map(Number);
  const parsed = new Date(Date.UTC(year, month - 1, day));
  return parsed.getUTCFullYear() === year && parsed.getUTCMonth() === month - 1 && parsed.getUTCDate() === day;
}

function isValidDateTime(value) {
  return /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$/.test(value)
    && Number.isFinite(Date.parse(value));
}

function isValidTimezone(value) {
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: value }).format();
    return true;
  } catch {
    return false;
  }
}

function isSafeRepositoryPath(value) {
  if (!value || value.startsWith("/") || value.startsWith("\\") || /^[A-Za-z]:[\\/]/.test(value)) return false;
  const parts = value.replaceAll("\\", "/").split("/");
  return !parts.includes("..") && !parts.includes("") && !value.includes("\0");
}

function validateType(value, type, idPattern) {
  switch (type) {
    case "integer":
      return /^-?\d+$/.test(value);
    case "number":
      return value.trim() !== "" && Number.isFinite(Number(value));
    case "id":
      return idPattern.test(value);
    case "datetime":
      return isValidDateTime(value);
    case "date":
      return isValidDate(value);
    case "country_code":
      return /^[A-Z]{2}$/.test(value);
    case "currency":
      return /^[A-Z]{3}$/.test(value);
    case "url": {
      try {
        const parsed = new URL(value);
        return parsed.protocol === "https:" || parsed.protocol === "http:";
      } catch {
        return false;
      }
    }
    case "timezone":
      return isValidTimezone(value);
    case "sha256":
      return /^[a-f0-9]{64}$/.test(value);
    case "git_sha":
      return /^[a-f0-9]{7,40}$/.test(value);
    case "repo_path":
      return isSafeRepositoryPath(value);
    case "boolean":
      return value === "true" || value === "false";
    default:
      fail(`csv-contracts.json: unknown type ${type}`);
      return true;
  }
}

function validateCsvContracts() {
  let specification;
  try {
    specification = JSON.parse(readFileSync(contractPath, "utf8"));
  } catch (error) {
    fail(`marketing/data/schemas/csv-contracts.json: ${error.message}`);
    return { contracts: new Map(), idPattern: /^$/ };
  }

  const idPattern = new RegExp(specification.id_pattern);
  const contractResults = new Map();
  const contractNames = new Set();

  for (const contract of specification.contracts ?? []) {
    counters.csvContracts += 1;
    if (contractNames.has(contract.name)) fail(`csv-contracts.json: duplicate contract name ${contract.name}`);
    contractNames.add(contract.name);

    const absolutePath = join(repositoryRoot, contract.path);
    const result = readCsv(absolutePath);
    contractResults.set(contract.name, { ...result, contract, absolutePath });
    if (!arraysEqual(result.header, contract.header)) {
      fail(`${contract.path}: header does not exactly match the ${contract.name} contract`);
    }

    const primaryKeys = new Set();
    result.rows.forEach((row, rowIndex) => {
      const line = rowIndex + 2;
      counters.csvRows += 1;
      for (const field of contract.required ?? []) {
        if ((row[field] ?? "") === "") fail(`${contract.path}:${line}: required field ${field} is blank`);
      }
      for (const [field, values] of Object.entries(contract.enums ?? {})) {
        const value = row[field] ?? "";
        if (value !== "" && !values.includes(value)) {
          fail(`${contract.path}:${line}: ${field}=${JSON.stringify(value)} is outside the contract enum`);
        }
      }
      for (const [field, type] of Object.entries(contract.types ?? {})) {
        const value = row[field] ?? "";
        if (value !== "" && !validateType(value, type, idPattern)) {
          fail(`${contract.path}:${line}: ${field}=${JSON.stringify(value)} is not a valid ${type}`);
        }
      }
      if ((contract.primary_key ?? []).length > 0) {
        const key = contract.primary_key.map((field) => row[field] ?? "").join("\u001f");
        if (primaryKeys.has(key)) fail(`${contract.path}:${line}: duplicate primary key ${JSON.stringify(key)}`);
        primaryKeys.add(key);
      }

      if (row.age_min && row.age_max && Number(row.age_min) > Number(row.age_max)) {
        fail(`${contract.path}:${line}: age_min exceeds age_max`);
      }
      if (row.planned_start_date && row.planned_end_date && row.planned_start_date > row.planned_end_date) {
        fail(`${contract.path}:${line}: planned_start_date is after planned_end_date`);
      }
      if (row.coverage_start && row.coverage_end && row.coverage_start > row.coverage_end) {
        fail(`${contract.path}:${line}: coverage_start is after coverage_end`);
      }
    });
  }

  for (const { rows, contract } of contractResults.values()) {
    for (const foreignKey of contract.foreign_keys ?? []) {
      const target = contractResults.get(foreignKey.target);
      if (!target) {
        fail(`csv-contracts.json: ${contract.name}.${foreignKey.field} targets missing contract ${foreignKey.target}`);
        continue;
      }
      const allowed = new Set(target.rows.map((row) => row[foreignKey.target_field]));
      rows.forEach((row, rowIndex) => {
        const value = row[foreignKey.field] ?? "";
        if (value === "" && foreignKey.allow_blank) return;
        if (value !== "" && !allowed.has(value)) {
          fail(`${contract.path}:${rowIndex + 2}: ${foreignKey.field}=${value} has no ${foreignKey.target}.${foreignKey.target_field}`);
        }
      });
    }
  }

  return { contracts: contractResults, idPattern };
}

const forbiddenDataKeys = new Set([
  "user_id", "install_id", "session_id", "device_id", "advertising_id", "idfa", "gaid",
  "ip_address", "email", "email_address", "phone", "phone_number", "full_name", "first_name",
  "last_name", "username", "profile_url", "birth_date", "date_of_birth", "birth_time",
  "birth_place", "latitude", "longitude", "auth_token", "access_token", "refresh_token",
  "qr_payload", "voice_transcript", "chat_text",
]);

function scanObjectKeys(value, label, pointer = "$") {
  if (Array.isArray(value)) {
    value.forEach((entry, index) => scanObjectKeys(entry, label, `${pointer}[${index}]`));
    return;
  }
  if (!value || typeof value !== "object") return;
  for (const [key, child] of Object.entries(value)) {
    if (forbiddenDataKeys.has(key.toLowerCase())) fail(`${label}:${pointer}: prohibited user-level key ${key}`);
    scanObjectKeys(child, label, `${pointer}.${key}`);
  }
}

function validateJsonSyntaxAndPrivacy() {
  for (const absolutePath of walk(marketingRoot)) {
    const extension = extname(absolutePath).toLowerCase();
    const label = repoPath(absolutePath);
    if (extension === ".csv") {
      const { header } = readCsv(absolutePath);
      for (const field of header) {
        if (forbiddenDataKeys.has(field.toLowerCase())) fail(`${label}: prohibited user-level column ${field}`);
      }
    } else if (extension === ".json") {
      try {
        const value = JSON.parse(readFileSync(absolutePath, "utf8"));
        counters.jsonFiles += 1;
        const isSchemaOrTemplate = label.includes("/schemas/") || label.includes("/templates/");
        if (!isSchemaOrTemplate) scanObjectKeys(value, label);
      } catch (error) {
        fail(`${label}: invalid JSON: ${error.message}`);
      }
    } else if (extension === ".jsonl") {
      const lines = readFileSync(absolutePath, "utf8").split(/\r?\n/);
      lines.forEach((line, index) => {
        if (!line.trim()) return;
        try {
          const value = JSON.parse(line);
          counters.jsonlRows += 1;
          if (!label.includes("/templates/")) scanObjectKeys(value, label, `$[line ${index + 1}]`);
        } catch (error) {
          fail(`${label}:${index + 1}: invalid JSONL: ${error.message}`);
        }
      });
    }
  }
}

function jsonTypeMatches(value, expected) {
  if (expected === "null") return value === null;
  if (expected === "array") return Array.isArray(value);
  if (expected === "integer") return Number.isInteger(value);
  if (expected === "number") return typeof value === "number" && Number.isFinite(value);
  if (expected === "object") return value !== null && typeof value === "object" && !Array.isArray(value);
  return typeof value === expected;
}

function resolveLocalRef(rootSchema, reference) {
  if (!reference.startsWith("#/")) return null;
  return reference.slice(2).split("/").reduce((current, part) => current?.[part.replaceAll("~1", "/").replaceAll("~0", "~")], rootSchema);
}

function validateAgainstSchema(value, schema, rootSchema, label, pointer = "$") {
  if (schema.$ref) {
    const resolved = resolveLocalRef(rootSchema, schema.$ref);
    if (!resolved) {
      fail(`${label}:${pointer}: unresolved schema reference ${schema.$ref}`);
      return;
    }
    validateAgainstSchema(value, resolved, rootSchema, label, pointer);
    return;
  }

  if (Object.hasOwn(schema, "const") && JSON.stringify(value) !== JSON.stringify(schema.const)) {
    fail(`${label}:${pointer}: expected constant ${JSON.stringify(schema.const)}`);
  }
  if (schema.enum && !schema.enum.some((entry) => JSON.stringify(entry) === JSON.stringify(value))) {
    fail(`${label}:${pointer}: value ${JSON.stringify(value)} is outside the schema enum`);
  }

  const expectedTypes = schema.type ? (Array.isArray(schema.type) ? schema.type : [schema.type]) : [];
  if (expectedTypes.length > 0 && !expectedTypes.some((type) => jsonTypeMatches(value, type))) {
    fail(`${label}:${pointer}: expected type ${expectedTypes.join("|")}`);
    return;
  }
  if (value === null) return;

  if (typeof value === "string") {
    if (schema.minLength !== undefined && value.length < schema.minLength) fail(`${label}:${pointer}: string is shorter than ${schema.minLength}`);
    if (schema.pattern && !new RegExp(schema.pattern).test(value)) fail(`${label}:${pointer}: string does not match ${schema.pattern}`);
    if (schema.format === "date" && !isValidDate(value)) fail(`${label}:${pointer}: invalid date`);
    if (schema.format === "date-time" && !isValidDateTime(value)) fail(`${label}:${pointer}: invalid date-time`);
  }
  if (typeof value === "number") {
    if (schema.minimum !== undefined && value < schema.minimum) fail(`${label}:${pointer}: number is below minimum ${schema.minimum}`);
    if (schema.maximum !== undefined && value > schema.maximum) fail(`${label}:${pointer}: number exceeds maximum ${schema.maximum}`);
    if (schema.exclusiveMinimum !== undefined && value <= schema.exclusiveMinimum) fail(`${label}:${pointer}: number must exceed ${schema.exclusiveMinimum}`);
    if (schema.exclusiveMaximum !== undefined && value >= schema.exclusiveMaximum) fail(`${label}:${pointer}: number must be below ${schema.exclusiveMaximum}`);
  }
  if (Array.isArray(value)) {
    if (schema.minItems !== undefined && value.length < schema.minItems) fail(`${label}:${pointer}: array has fewer than ${schema.minItems} items`);
    if (schema.items) value.forEach((item, index) => validateAgainstSchema(item, schema.items, rootSchema, label, `${pointer}[${index}]`));
  } else if (value && typeof value === "object") {
    for (const field of schema.required ?? []) {
      if (!Object.hasOwn(value, field)) fail(`${label}:${pointer}: missing required property ${field}`);
    }
    if (schema.additionalProperties === false) {
      for (const field of Object.keys(value)) {
        if (!Object.hasOwn(schema.properties ?? {}, field)) fail(`${label}:${pointer}: unexpected property ${field}`);
      }
    }
    for (const [field, childSchema] of Object.entries(schema.properties ?? {})) {
      if (Object.hasOwn(value, field)) validateAgainstSchema(value[field], childSchema, rootSchema, label, `${pointer}.${field}`);
    }
  }
}

function readJson(absolutePath) {
  try {
    return JSON.parse(readFileSync(absolutePath, "utf8"));
  } catch {
    return null;
  }
}

function validateStructuredArtifacts(contractResults) {
  const schemaDirectory = join(marketingRoot, "data/schemas");
  const planSchema = readJson(join(schemaDirectory, "experiment-plan.schema.json"));
  const amendmentSchema = readJson(join(schemaDirectory, "experiment-amendment.schema.json"));
  const reportSchema = readJson(join(schemaDirectory, "report-metadata.schema.json"));
  const promptSchema = readJson(join(schemaDirectory, "veo-prompt.schema.json"));
  const allFiles = walk(marketingRoot);

  const planFiles = allFiles.filter((file) => repoPath(file).startsWith("marketing/experiments/") && file.endsWith("/plan.json"));
  const amendmentFiles = allFiles.filter((file) => repoPath(file).startsWith("marketing/experiments/") && file.endsWith(".jsonl"));
  const reportFiles = allFiles.filter((file) => repoPath(file).startsWith("marketing/analytics/reports/") && file.endsWith(".metadata.json"));
  const promptFiles = allFiles.filter((file) => repoPath(file).startsWith("marketing/creative/") && file.endsWith(".prompt.json"));

  const campaigns = new Set(contractResults.get("campaigns")?.rows.map((row) => row.campaign_id) ?? []);
  const audiences = new Set(contractResults.get("audiences")?.rows.map((row) => row.audience_id) ?? []);
  const creatives = new Set(contractResults.get("creatives")?.rows.map((row) => row.creative_id) ?? []);
  const metrics = new Set(contractResults.get("metrics")?.rows.map((row) => row.metric_key) ?? []);

  for (const absolutePath of planFiles) {
    const label = repoPath(absolutePath);
    const plan = readJson(absolutePath);
    if (!plan || !planSchema) continue;
    counters.experimentPlans += 1;
    validateAgainstSchema(plan, planSchema, planSchema, label);
    if (!campaigns.has(plan.campaign_id)) fail(`${label}: campaign_id ${plan.campaign_id} is not registered`);
    if (!audiences.has(plan.audience_id)) fail(`${label}: audience_id ${plan.audience_id} is not registered`);
    const metricKeys = [plan.primary_metric?.metric_key, ...(plan.secondary_metrics ?? []), ...(plan.guardrail_metrics ?? [])].filter(Boolean);
    metricKeys.forEach((metric) => {
      if (!metrics.has(metric)) fail(`${label}: metric ${metric} is not registered`);
    });
    const armIds = new Set();
    let totalWeight = 0;
    for (const arm of plan.arms ?? []) {
      if (armIds.has(arm.arm_id)) fail(`${label}: duplicate arm_id ${arm.arm_id}`);
      armIds.add(arm.arm_id);
      totalWeight += Number(arm.traffic_weight ?? 0);
      for (const creativeId of arm.creative_ids ?? []) {
        if (!creatives.has(creativeId)) fail(`${label}: creative_id ${creativeId} is not registered`);
      }
    }
    if (Math.abs(totalWeight - 1) > 1e-9) fail(`${label}: arm traffic weights sum to ${totalWeight}, not 1`);
    if ((plan.minimum_duration_days ?? 0) > (plan.maximum_duration_days ?? 0)) fail(`${label}: minimum duration exceeds maximum duration`);
    const observational = ["organic_observational", "matched_observational", "optimized_delivery_observational"].includes(plan.design_type);
    if (observational && plan.causal_claim_allowed !== false) fail(`${label}: observational designs must set causal_claim_allowed=false`);
  }

  for (const absolutePath of amendmentFiles) {
    const label = repoPath(absolutePath);
    readFileSync(absolutePath, "utf8").split(/\r?\n/).forEach((line, index) => {
      if (!line.trim()) return;
      try {
        const value = JSON.parse(line);
        if (amendmentSchema) validateAgainstSchema(value, amendmentSchema, amendmentSchema, `${label}:${index + 1}`);
      } catch {
        // The syntax validator reports the parse failure once.
      }
    });
  }
  for (const absolutePath of reportFiles) {
    const value = readJson(absolutePath);
    if (value && reportSchema) validateAgainstSchema(value, reportSchema, reportSchema, repoPath(absolutePath));
  }
  for (const absolutePath of promptFiles) {
    const value = readJson(absolutePath);
    if (value && promptSchema) validateAgainstSchema(value, promptSchema, promptSchema, repoPath(absolutePath));
  }
}

function countExact(text, needle) {
  return text.split(needle).length - 1;
}

function validateCreativePack(contractResults) {
  const packDirectory = join(marketingRoot, "creative/campaigns/launch-001");
  const matrixPath = join(packDirectory, "creative-test-matrix.csv");
  if (!existsSync(matrixPath)) return;
  const matrix = readCsv(matrixPath);
  const required = [
    "campaign_id", "concept_id", "prompt_id", "audience_id", "concept_slug", "proof_shot_keys",
    "veo_seconds", "target_edit_seconds", "primary_metric", "secondary_metric", "status",
  ];
  for (const field of required) if (!matrix.header.includes(field)) fail(`${repoPath(matrixPath)}: missing required column ${field}`);
  if (matrix.rows.length === 0) fail(`${repoPath(matrixPath)}: launch matrix has no concepts`);
  counters.creativeRows += matrix.rows.length;

  const campaigns = new Set(contractResults.get("campaigns")?.rows.map((row) => row.campaign_id) ?? []);
  const audiences = new Set(contractResults.get("audiences")?.rows.map((row) => row.audience_id) ?? []);
  const concepts = new Set(contractResults.get("concepts")?.rows.map((row) => row.concept_id) ?? []);
  const promptRows = contractResults.get("prompts")?.rows ?? [];
  const prompts = new Set(promptRows.map((row) => row.prompt_id));
  const metrics = new Set(contractResults.get("metrics")?.rows.map((row) => row.metric_key) ?? []);
  const promptDocument = readFileSync(join(packDirectory, "veo-prompts.md"), "utf8");
  const editDocument = readFileSync(join(packDirectory, "edit-recipes.md"), "utf8");
  const voiceDocument = readFileSync(join(packDirectory, "voiceovers.md"), "utf8");
  const shotDocument = readFileSync(join(packDirectory, "app-capture-shot-list.md"), "utf8");
  const availableShots = new Set(shotDocument.match(/SH-[A-Z]+-\d+/g) ?? []);
  const seenConcepts = new Set();
  const seenPrompts = new Set();

  for (const [index, row] of matrix.rows.entries()) {
    const line = index + 2;
    if (!campaigns.has(row.campaign_id)) fail(`${repoPath(matrixPath)}:${line}: unknown campaign_id ${row.campaign_id}`);
    if (!audiences.has(row.audience_id)) fail(`${repoPath(matrixPath)}:${line}: unknown audience_id ${row.audience_id}`);
    if (!concepts.has(row.concept_id)) fail(`${repoPath(matrixPath)}:${line}: unknown concept_id ${row.concept_id}`);
    if (!prompts.has(row.prompt_id)) fail(`${repoPath(matrixPath)}:${line}: unknown prompt_id ${row.prompt_id}`);
    if (seenConcepts.has(row.concept_id)) fail(`${repoPath(matrixPath)}:${line}: duplicate concept_id ${row.concept_id}`);
    if (seenPrompts.has(row.prompt_id)) fail(`${repoPath(matrixPath)}:${line}: duplicate prompt_id ${row.prompt_id}`);
    seenConcepts.add(row.concept_id);
    seenPrompts.add(row.prompt_id);
    if (!["8", "12"].includes(row.veo_seconds)) fail(`${repoPath(matrixPath)}:${line}: veo_seconds must be 8 or 12`);
    if (!Number.isFinite(Number(row.target_edit_seconds)) || Number(row.target_edit_seconds) < 8 || Number(row.target_edit_seconds) > 30) {
      fail(`${repoPath(matrixPath)}:${line}: target_edit_seconds must be between 8 and 30`);
    }
    for (const metric of [row.primary_metric, row.secondary_metric]) {
      if (!metrics.has(metric)) fail(`${repoPath(matrixPath)}:${line}: metric ${metric} is not registered`);
    }
    for (const shot of row.proof_shot_keys.split("|").filter(Boolean)) {
      if (!availableShots.has(shot)) fail(`${repoPath(matrixPath)}:${line}: proof shot ${shot} is not in the capture catalogue`);
    }
    if (countExact(promptDocument, `**Prompt ID:** \`${row.prompt_id}\``) !== 1) {
      fail(`${repoPath(matrixPath)}:${line}: ${row.prompt_id} must appear exactly once as a Veo Prompt ID`);
    }
    if (countExact(editDocument, `**Source:** \`${row.prompt_id}\``) !== 1) {
      fail(`${repoPath(matrixPath)}:${line}: ${row.prompt_id} must appear exactly once as an edit Source`);
    }
    const conceptCode = row.prompt_id.split("_").at(-1);
    const voiceHeadingPattern = new RegExp(`^## \\d+ .+\\\`${conceptCode.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\\``, "m");
    if (!voiceHeadingPattern.test(voiceDocument)) fail(`${repoPath(matrixPath)}:${line}: voiceover section missing for ${conceptCode}`);

    const sectionStart = editDocument.indexOf(`**Source:** \`${row.prompt_id}\``);
    const nextSection = editDocument.indexOf("\n## ", sectionStart + 1);
    const section = editDocument.slice(sectionStart, nextSection === -1 ? undefined : nextSection);
    const proofStarts = [...section.matchAll(/^\|\s*([0-9]+(?:\.[0-9]+)?)[–-][^|]*\|[^\n]*SH-[A-Z]+-\d+/gm)].map((match) => Number(match[1]));
    if (proofStarts.length === 0 || Math.min(...proofStarts) > 3) {
      fail(`${repoPath(matrixPath)}:${line}: real app proof must begin by second 3 in the edit recipe`);
    }
  }

  const packPrompts = new Set(promptRows.filter((row) => row.prompt_path === "marketing/creative/campaigns/launch-001/veo-prompts.md").map((row) => row.prompt_id));
  for (const prompt of packPrompts) if (!seenPrompts.has(prompt)) fail(`${repoPath(matrixPath)}: registered launch prompt ${prompt} is absent from the matrix`);
  for (const prompt of seenPrompts) if (!packPrompts.has(prompt)) fail(`${repoPath(matrixPath)}: matrix prompt ${prompt} is not registered to this launch pack`);
}

function sha256(absolutePath) {
  return createHash("sha256").update(readFileSync(absolutePath)).digest("hex");
}

function validateDriveSnapshots(contractResults) {
  const result = contractResults.get("drive_documents");
  if (!result) return;
  for (const [index, row] of result.rows.entries()) {
    if (row.status !== "verified_snapshot") continue;
    counters.driveSnapshots += 1;
    const absolutePath = join(repositoryRoot, row.source_path);
    if (!existsSync(absolutePath)) {
      fail(`${result.contract.path}:${index + 2}: snapshot source ${row.source_path} is missing`);
      continue;
    }
    const currentBytes = statSync(absolutePath).size;
    const currentHash = sha256(absolutePath);
    if (String(currentBytes) !== row.bytes) fail(`${result.contract.path}:${index + 2}: ${row.source_path} byte count changed since Drive upload`);
    if (currentHash !== row.sha256) fail(`${result.contract.path}:${index + 2}: ${row.source_path} SHA-256 changed since Drive upload`);
    try {
      execFileSync("git", ["cat-file", "-e", `${row.source_git_sha}^{commit}`], { cwd: repositoryRoot, stdio: "ignore" });
    } catch {
      fail(`${result.contract.path}:${index + 2}: source_git_sha ${row.source_git_sha} is not a local commit`);
    }
  }
}

const forbiddenBinaryExtensions = new Set([
  ".mp4", ".mov", ".m4v", ".avi", ".mkv", ".webm", ".wav", ".mp3", ".m4a", ".aac",
  ".aiff", ".flac", ".psd", ".prproj", ".drp", ".dra", ".capcut", ".fcpxml", ".zip",
  ".7z", ".rar", ".tar", ".tgz", ".gz",
]);

function validateBinaryIsolation() {
  let tracked = [];
  try {
    const output = execFileSync("git", ["ls-files", "-z", "--", "marketing"], { cwd: repositoryRoot });
    tracked = output.toString("utf8").split("\0").filter(Boolean);
  } catch (error) {
    fail(`git ls-files failed while checking marketing binaries: ${error.message}`);
  }
  for (const file of tracked) {
    if (forbiddenBinaryExtensions.has(extname(file).toLowerCase())) fail(`${file}: binary media/editor file is tracked by Git`);
  }
  for (const absolutePath of walk(marketingRoot)) {
    if (!forbiddenBinaryExtensions.has(extname(absolutePath).toLowerCase())) continue;
    const file = repoPath(absolutePath);
    try {
      execFileSync("git", ["check-ignore", "-q", "--", file], { cwd: repositoryRoot, stdio: "ignore" });
    } catch {
      fail(`${file}: binary exists but is not protected by a Git ignore rule`);
    }
  }
}

function validateRegisteredPaths(contractResults) {
  const checks = [
    ["prompts", "prompt_path"],
    ["creatives", "edit_recipe_path"],
    ["experiments", "plan_path"],
  ];
  for (const [contractName, field] of checks) {
    const result = contractResults.get(contractName);
    if (!result) continue;
    result.rows.forEach((row, index) => {
      const value = row[field];
      if (value && !existsSync(join(repositoryRoot, value))) fail(`${result.contract.path}:${index + 2}: ${field} does not exist: ${value}`);
    });
  }
}

const { contracts } = validateCsvContracts();
validateJsonSyntaxAndPrivacy();
validateStructuredArtifacts(contracts);
validateCreativePack(contracts);
validateDriveSnapshots(contracts);
validateBinaryIsolation();
validateRegisteredPaths(contracts);

if (counters.experimentPlans === 0) notice("No executable experiment plan is registered yet; the templates remain unvalidated placeholders by design.");
if ((contracts.get("publications")?.rows.length ?? 0) === 0) notice("No publication rows exist yet; performance reporting correctly remains at a zero-data baseline.");

if (failures.length > 0) {
  console.error(`Marketing validation failed with ${failures.length} issue${failures.length === 1 ? "" : "s"}:`);
  failures.forEach((message) => console.error(`  - ${message}`));
  process.exitCode = 1;
} else {
  console.log("Marketing validation passed.");
  console.log(`  CSV contracts: ${counters.csvContracts}`);
  console.log(`  Contracted data rows: ${counters.csvRows}`);
  console.log(`  JSON files / JSONL rows: ${counters.jsonFiles} / ${counters.jsonlRows}`);
  console.log(`  Launch creative rows: ${counters.creativeRows}`);
  console.log(`  Verified Drive snapshots: ${counters.driveSnapshots}`);
  console.log(`  Executable experiment plans: ${counters.experimentPlans}`);
  notices.forEach((message) => console.log(`  Note: ${message}`));
}
