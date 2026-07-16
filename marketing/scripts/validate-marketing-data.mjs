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
const driveSnapshotFailures = [];
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

function failDriveSnapshot(message) {
  driveSnapshotFailures.push(message);
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
    case "nonnegative_integer":
      return /^\d+$/.test(value);
    case "number":
      return value.trim() !== "" && Number.isFinite(Number(value));
    case "nonnegative_number":
      return value.trim() !== "" && Number.isFinite(Number(value)) && Number(value) >= 0;
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

function rowsById(contractResults, contractName, idField) {
  return new Map((contractResults.get(contractName)?.rows ?? []).map((row) => [row[idField], row]));
}

function hashText(text) {
  return createHash("sha256").update(text).digest("hex");
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
  const reportDocuments = allFiles.filter((file) => repoPath(file).startsWith("marketing/analytics/reports/") && file.endsWith(".md"));
  const promptFiles = allFiles.filter((file) => repoPath(file).startsWith("marketing/creative/") && file.endsWith(".prompt.json"));

  const campaigns = new Set(contractResults.get("campaigns")?.rows.map((row) => row.campaign_id) ?? []);
  const audiences = new Set(contractResults.get("audiences")?.rows.map((row) => row.audience_id) ?? []);
  const creatives = new Set(contractResults.get("creatives")?.rows.map((row) => row.creative_id) ?? []);
  const planMetricKeys = new Set(contractResults.get("metrics")?.rows.map((row) => row.metric_key) ?? []);

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
      if (!planMetricKeys.has(metric)) fail(`${label}: metric ${metric} is not registered`);
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
  const ingestionIds = new Set(contractResults.get("ingestion_runs")?.rows.map((row) => row.ingestion_id) ?? []);
  for (const absolutePath of reportDocuments) {
    const metadataPath = absolutePath.replace(/\.md$/, ".metadata.json");
    if (!existsSync(metadataPath)) fail(`${repoPath(absolutePath)}: report is missing sibling metadata JSON`);
  }
  for (const absolutePath of reportFiles) {
    const value = readJson(absolutePath);
    if (!value || !reportSchema) continue;
    const label = repoPath(absolutePath);
    validateAgainstSchema(value, reportSchema, reportSchema, label);
    const reportPath = absolutePath.replace(/\.metadata\.json$/, ".md");
    if (!existsSync(reportPath)) {
      fail(`${label}: metadata has no sibling report Markdown`);
      continue;
    }
    if (!(value.input_hashes ?? []).includes(sha256(reportPath))) fail(`${label}: input_hashes must include the sibling report SHA-256`);
    for (const sourceId of value.source_export_ids ?? []) {
      if (!ingestionIds.has(sourceId)) fail(`${label}: source_export_id ${sourceId} is not registered`);
    }
    if (value.period_start && value.period_end && value.period_start > value.period_end) fail(`${label}: period_start is after period_end`);
    if (value.data_cutoff_utc && value.generated_at_utc && Date.parse(value.data_cutoff_utc) > Date.parse(value.generated_at_utc)) fail(`${label}: data cutoff is after report generation`);
    try {
      execFileSync("git", ["cat-file", "-e", `${value.analysis_script_git_sha}^{commit}`], { cwd: repositoryRoot, stdio: "ignore" });
    } catch {
      fail(`${label}: analysis_script_git_sha ${value.analysis_script_git_sha} is not a local commit`);
    }
  }
  for (const absolutePath of promptFiles) {
    const value = readJson(absolutePath);
    if (value && promptSchema) validateAgainstSchema(value, promptSchema, promptSchema, repoPath(absolutePath));
  }
}

function countExact(text, needle) {
  return text.split(needle).length - 1;
}

function extractRegisteredPromptBlock(document, promptId, label) {
  const marker = `**Prompt ID:** \`${promptId}\``;
  if (countExact(document, marker) !== 1) {
    fail(`${label}: ${promptId} must have exactly one Prompt ID marker`);
    return null;
  }
  const markerIndex = document.indexOf(marker);
  const sectionEndIndex = document.indexOf("\n## ", markerIndex + marker.length);
  const sectionEnd = sectionEndIndex === -1 ? document.length : sectionEndIndex;
  const fenceToken = "```text\n";
  const fenceIndex = document.indexOf(fenceToken, markerIndex + marker.length);
  if (fenceIndex === -1 || fenceIndex >= sectionEnd) {
    fail(`${label}: ${promptId} has no text fence in its registered section`);
    return null;
  }
  const contentStart = fenceIndex + fenceToken.length;
  const contentEnd = document.indexOf("\n```", contentStart);
  if (contentEnd === -1 || contentEnd > sectionEnd) {
    fail(`${label}: ${promptId} has no closing text fence in its registered section`);
    return null;
  }
  const secondFence = document.indexOf(fenceToken, contentEnd + 4);
  if (secondFence !== -1 && secondFence < sectionEnd) {
    fail(`${label}: ${promptId} has more than one text fence; its hash boundary is ambiguous`);
    return null;
  }
  return document.slice(contentStart, contentEnd);
}

function validatePromptBlockHashes(contractResults) {
  const result = contractResults.get("prompts");
  if (!result) return;
  const documentCache = new Map();
  for (const [index, row] of result.rows.entries()) {
    const line = index + 2;
    const absolutePath = join(repositoryRoot, row.prompt_path);
    if (!existsSync(absolutePath)) continue; // Registered-path validation reports this once.
    if (!documentCache.has(absolutePath)) documentCache.set(absolutePath, readFileSync(absolutePath, "utf8"));
    const promptBlock = extractRegisteredPromptBlock(documentCache.get(absolutePath), row.prompt_id, row.prompt_path);
    if (promptBlock === null) continue;
    const currentHash = hashText(promptBlock);
    if (currentHash !== row.prompt_content_sha256) {
      fail(`${result.contract.path}:${line}: ${row.prompt_id} prompt block SHA-256 is ${currentHash}, expected ${row.prompt_content_sha256}`);
    }
    if (Number(row.prompt_version) < 1) fail(`${result.contract.path}:${line}: prompt_version must be at least 1`);
  }
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
  const launchMetricKeys = new Set(contractResults.get("metrics")?.rows.map((row) => row.metric_key) ?? []);
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
      if (!launchMetricKeys.has(metric)) fail(`${repoPath(matrixPath)}:${line}: metric ${metric} is not registered`);
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

function requireRowFields(row, fields, label) {
  for (const field of fields) {
    if ((row[field] ?? "") === "") fail(`${label}: ${field} is required for this kind/state`);
  }
}

function validateMediaAndCreativeState(contractResults) {
  const mediaResult = contractResults.get("media");
  const creativeResult = contractResults.get("creatives");
  if (!mediaResult || !creativeResult) return;

  const promptRows = rowsById(contractResults, "prompts", "prompt_id");
  const mediaRows = rowsById(contractResults, "media", "media_id");
  const creativeInputs = contractResults.get("creative_media_inputs")?.rows ?? [];
  const publications = contractResults.get("publications")?.rows ?? [];
  const productionStates = new Set(["verified", "approved", "published", "archived"]);
  const releasableStates = new Set(["approved", "published"]);
  const movingPictureKinds = new Set(["veo_render", "app_capture", "stock_video", "draft_export", "final_master", "published_file"]);
  const generatedKinds = new Set(["veo_render", "ai_voice"]);
  const licensedKinds = new Set(["stock_video", "stock_image", "music", "sfx"]);
  const allowedFolders = new Map([
    ["veo_render", new Set(["ai_veo"])],
    ["app_capture", new Set(["source_app_captures"])],
    ["ai_voice", new Set(["ai_voice"])],
    ["stock_video", new Set(["source_stock"])],
    ["stock_image", new Set(["source_stock"])],
    ["brand_asset", new Set(["source_brand_assets"])],
    ["music", new Set(["source_music"])],
    ["sfx", new Set(["source_music"])],
    ["edit_project", new Set(["edit_projects"])],
    ["draft_export", new Set(["exports_drafts", "exports_review"])],
    ["final_master", new Set(["exports_final"])],
    ["published_file", new Set(["published_instagram", "published_tiktok"])],
    ["reference", new Set(["source_references"])],
  ]);

  for (const [index, row] of mediaResult.rows.entries()) {
    const label = `${mediaResult.contract.path}:${index + 2}`;
    if (!row.filename.startsWith(row.media_id)) fail(`${label}: filename must begin with media_id ${row.media_id}`);
    if (row.parent_media_id === row.media_id) fail(`${label}: parent_media_id cannot reference itself`);
    if (row.drive_file_id && row.drive_web_url && !row.drive_web_url.includes(row.drive_file_id)) {
      fail(`${label}: drive_web_url does not contain drive_file_id`);
    }
    const folders = allowedFolders.get(row.kind);
    if (folders && !folders.has(row.drive_folder_key)) {
      fail(`${label}: kind=${row.kind} must use Drive folder ${[...folders].join(" or ")}, not ${row.drive_folder_key}`);
    }
    if (productionStates.has(row.status)) {
      requireRowFields(row, ["drive_file_id", "drive_web_url", "drive_folder_key", "sha256", "bytes"], label);
      if (Number(row.bytes) <= 0) fail(`${label}: production-state media must have bytes greater than zero`);
      if (["unknown", "reference_only"].includes(row.rights_basis) && row.kind !== "reference") {
        fail(`${label}: production-state media cannot use rights_basis=${row.rights_basis}`);
      }
    }
    if (releasableStates.has(row.status) && row.license_expiry && row.license_expiry < new Date().toISOString().slice(0, 10)) {
      fail(`${label}: approved/published media has an expired license (${row.license_expiry})`);
    }
    if (generatedKinds.has(row.kind) && row.rights_basis !== "generated") {
      fail(`${label}: kind=${row.kind} must use rights_basis=generated`);
    }
    if (licensedKinds.has(row.kind) && !["licensed", "public_domain", "owned"].includes(row.rights_basis)) {
      fail(`${label}: kind=${row.kind} requires licensed, public_domain, or owned rights`);
    }
    if ((row.rights_basis === "licensed" || row.rights_basis === "public_domain") && !row.license_source) {
      fail(`${label}: rights_basis=${row.rights_basis} requires license_source provenance`);
    }
    if (row.kind === "reference") {
      if (row.rights_basis !== "reference_only") fail(`${label}: reference media must use rights_basis=reference_only`);
      if (releasableStates.has(row.status)) fail(`${label}: reference-only media cannot be approved or published`);
    }
    if (movingPictureKinds.has(row.kind)) {
      requireRowFields(row, ["duration_ms", "width_px", "height_px", "fps", "video_codec"], label);
      for (const field of ["duration_ms", "width_px", "height_px", "fps"]) {
        if (row[field] && Number(row[field]) <= 0) fail(`${label}: ${field} must be greater than zero for ${row.kind}`);
      }
    }
    if (row.kind === "veo_render") {
      requireRowFields(row, ["prompt_id", "model_provider", "model_name", "model_version", "seed"], label);
      const prompt = promptRows.get(row.prompt_id);
      if (prompt && !["approved", "generated"].includes(prompt.status)) {
        fail(`${label}: Veo render references prompt ${row.prompt_id} in status=${prompt.status}`);
      }
    }
    if (row.kind === "app_capture") {
      requireRowFields(row, [
        "app_git_sha", "app_version", "app_build", "recorded_device", "recorded_os",
        "recorded_locale", "recorded_timezone", "fixture_version", "network_mode",
        "operator_code", "recorded_at_utc",
      ], label);
      if (row.rights_basis !== "owned") fail(`${label}: app captures must use rights_basis=owned`);
    }
    if (row.kind === "ai_voice") {
      requireRowFields(row, ["duration_ms", "audio_codec", "model_provider", "model_name", "model_version"], label);
      if (row.duration_ms && Number(row.duration_ms) <= 0) fail(`${label}: AI voice duration_ms must be greater than zero`);
    }
    if (["music", "sfx"].includes(row.kind)) requireRowFields(row, ["duration_ms", "audio_codec"], label);
    if (row.kind === "stock_image" || row.kind === "brand_asset") requireRowFields(row, ["width_px", "height_px"], label);
    if (row.kind === "published_file" && row.status !== "published") fail(`${label}: published_file media must use status=published`);
  }

  for (const [index, row] of creativeResult.rows.entries()) {
    const label = `${creativeResult.contract.path}:${index + 2}`;
    const prompt = promptRows.get(row.prompt_id);
    const finalMedia = mediaRows.get(row.final_media_id);
    const voiceMedia = mediaRows.get(row.voiceover_media_id);
    const inputs = creativeInputs.filter((input) => input.creative_id === row.creative_id);
    if (row.supersedes_creative_id === row.creative_id) fail(`${label}: supersedes_creative_id cannot reference itself`);
    if (prompt && prompt.concept_id !== row.concept_id) {
      fail(`${label}: prompt ${row.prompt_id} belongs to ${prompt.concept_id}, not creative concept ${row.concept_id}`);
    }
    if (voiceMedia && voiceMedia.kind !== "ai_voice") fail(`${label}: voiceover_media_id must reference kind=ai_voice`);
    if (row.status !== "draft" && row.status !== "rejected") {
      requireRowFields(row, ["final_media_id", "content_sha256"], label);
      if (inputs.length === 0) fail(`${label}: ${row.status} creative has no registered media inputs`);
      if (!inputs.some((input) => mediaRows.get(input.media_id)?.kind === "app_capture")) {
        fail(`${label}: ${row.status} creative must include real app_capture proof`);
      }
    }
    if (finalMedia) {
      if (!["final_master", "published_file"].includes(finalMedia.kind)) {
        fail(`${label}: final_media_id must reference final_master or published_file media`);
      }
      if (row.content_sha256 && row.content_sha256 !== finalMedia.sha256) {
        fail(`${label}: content_sha256 must equal final media SHA-256`);
      }
      if (row.duration_ms && finalMedia.duration_ms && Math.abs(Number(row.duration_ms) - Number(finalMedia.duration_ms)) > 100) {
        fail(`${label}: creative duration differs from final media by more than 100 ms`);
      }
      if (["approved", "published"].includes(row.status) && !["approved", "published"].includes(finalMedia.status)) {
        fail(`${label}: ${row.status} creative references final media in status=${finalMedia.status}`);
      }
    }
    if (["approved", "published"].includes(row.status)) {
      for (const input of inputs) {
        const media = mediaRows.get(input.media_id);
        if (media && !["verified", "approved", "published", "archived"].includes(media.status)) {
          fail(`${label}: approved/published creative uses media ${media.media_id} in status=${media.status}`);
        }
      }
    }
    if (row.status === "published" && !publications.some((publication) => publication.creative_id === row.creative_id && publication.status === "published")) {
      fail(`${label}: published creative has no published publication row`);
    }
  }
}

function validateTimelineRanges(contractResults) {
  const result = contractResults.get("creative_media_inputs");
  if (!result) return;
  const creativeRows = rowsById(contractResults, "creatives", "creative_id");
  const mediaRows = rowsById(contractResults, "media", "media_id");
  const layerRanges = new Map();
  for (const [index, row] of result.rows.entries()) {
    const label = `${result.contract.path}:${index + 2}`;
    const start = Number(row.timeline_start_ms);
    const end = Number(row.timeline_end_ms);
    const creative = creativeRows.get(row.creative_id);
    const media = mediaRows.get(row.media_id);
    if (!(start < end)) fail(`${label}: timeline_start_ms must be less than timeline_end_ms`);
    if (creative?.duration_ms && end > Number(creative.duration_ms)) {
      fail(`${label}: timeline_end_ms exceeds creative duration_ms=${creative.duration_ms}`);
    }
    const hasSourceIn = row.source_in_ms !== "";
    const hasSourceOut = row.source_out_ms !== "";
    if (hasSourceIn !== hasSourceOut) fail(`${label}: source_in_ms and source_out_ms must be supplied together`);
    if (hasSourceIn && hasSourceOut) {
      const sourceIn = Number(row.source_in_ms);
      const sourceOut = Number(row.source_out_ms);
      if (!(sourceIn < sourceOut)) fail(`${label}: source_in_ms must be less than source_out_ms`);
      if (media?.duration_ms && sourceOut > Number(media.duration_ms)) {
        fail(`${label}: source_out_ms exceeds media duration_ms=${media.duration_ms}`);
      }
    }
    if (media?.status === "rejected") fail(`${label}: rejected media ${row.media_id} cannot be a creative input`);
    const layerKey = `${row.creative_id}\u001f${row.layer}`;
    const previousRanges = layerRanges.get(layerKey) ?? [];
    if (previousRanges.some((range) => start < range.end && end > range.start)) {
      fail(`${label}: timeline overlaps another input on creative ${row.creative_id} layer ${row.layer}`);
    }
    previousRanges.push({ start, end });
    layerRanges.set(layerKey, previousRanges);
  }
}

function validatePublicationAudiences(contractResults) {
  const result = contractResults.get("publications");
  if (!result) return;
  const audiences = rowsById(contractResults, "audiences", "audience_id");
  const campaigns = rowsById(contractResults, "campaigns", "campaign_id");
  const creatives = rowsById(contractResults, "creatives", "creative_id");
  for (const [index, row] of result.rows.entries()) {
    const label = `${result.contract.path}:${index + 2}`;
    const audience = audiences.get(row.audience_id);
    const campaign = campaigns.get(row.campaign_id);
    const creative = creatives.get(row.creative_id);
    if (audience) {
      if (!audience.residence_country_code) fail(`${label}: publication audience must declare one residence_country_code`);
      if (audience.diaspora_status === "mixed") fail(`${label}: mixed umbrella audiences cannot be attached to a publication`);
      if (audience.diaspora_status === "nepal" && audience.residence_country_code !== "NP") fail(`${label}: Nepal audience must have residence_country_code=NP`);
      if (audience.diaspora_status === "diaspora" && audience.residence_country_code === "NP") fail(`${label}: diaspora audience must reside outside NP`);
      if (Number(audience.age_min) < 18) fail(`${label}: publications cannot target an audience whose age_min is below 18`);
    }
    if (row.utm_campaign !== row.campaign_id) fail(`${label}: utm_campaign must equal campaign_id`);
    if (row.utm_content !== row.publication_id) fail(`${label}: utm_content must equal publication_id`);
    if (row.utm_source !== row.platform) fail(`${label}: utm_source must equal platform`);
    const expectedMedium = row.delivery_type === "organic" ? "organic_social" : "paid_social";
    if (row.utm_medium !== expectedMedium) fail(`${label}: utm_medium must be ${expectedMedium}`);
    if (["scheduled", "published", "paused", "archived"].includes(row.status)) {
      requireRowFields(row, ["destination_url"], label);
      if (creative && !["approved", "published"].includes(creative.status)) fail(`${label}: publication requires an approved/published creative`);
      if (campaign && ["draft", "cancelled"].includes(campaign.status)) fail(`${label}: publication cannot run under campaign status=${campaign.status}`);
    }
    if (["published", "paused", "archived"].includes(row.status)) {
      requireRowFields(row, ["published_at_utc", "public_url"], label);
      if (row.delivery_type === "organic") requireRowFields(row, ["platform_post_id"], label);
      else requireRowFields(row, ["platform_campaign_id", "platform_adgroup_id", "platform_ad_id"], label);
    }
    if (row.delivery_type === "organic" && !["", "none"].includes(row.attribution_model)) {
      fail(`${label}: organic publication attribution_model must be blank or none until a reviewed mechanism exists`);
    }
  }
}

function validateExperimentLifecycle(contractResults) {
  const result = contractResults.get("experiments");
  if (!result) return;
  const registryRows = rowsById(contractResults, "experiments", "experiment_id");
  const publications = contractResults.get("publications")?.rows ?? [];
  const metricRows = rowsById(contractResults, "metrics", "metric_key");
  const plans = new Map();
  const globalArmIds = new Set();
  for (const absolutePath of walk(join(marketingRoot, "experiments"))) {
    if (!absolutePath.endsWith("/plan.json")) continue;
    const plan = readJson(absolutePath);
    if (!plan?.experiment_id) continue;
    const label = repoPath(absolutePath);
    if (plans.has(plan.experiment_id)) fail(`${label}: duplicate plan for experiment_id ${plan.experiment_id}`);
    plans.set(plan.experiment_id, { plan, label, absolutePath });
    if (absolutePath.split(sep).at(-2) !== plan.experiment_id) fail(`${label}: parent directory must equal experiment_id`);
    const registry = registryRows.get(plan.experiment_id);
    if (!registry) {
      fail(`${label}: experiment plan is not registered`);
      continue;
    }
    if (registry.plan_path !== label) fail(`${label}: registry plan_path is ${registry.plan_path}`);
    for (const field of ["title", "campaign_id", "audience_id", "design_type"]) {
      if (registry[field] !== plan[field]) fail(`${label}: ${field} disagrees with experiments.csv`);
    }
    if (registry.primary_metric !== plan.primary_metric?.metric_key) fail(`${label}: primary metric disagrees with experiments.csv`);
    const activeStates = new Set(["planned", "running", "paused", "completed"]);
    if (registry.status === "draft" && plan.status !== "draft") fail(`${label}: draft registry row requires plan status=draft`);
    if (activeStates.has(registry.status) && plan.status !== "planned") fail(`${label}: pre-registered plan must remain immutable with status=planned while registry tracks lifecycle state`);
    if (activeStates.has(registry.status)) {
      requireRowFields(registry, ["planned_start_at_utc", "planned_end_at_utc", "preregistered_commit"], `${result.contract.path}:${result.rows.indexOf(registry) + 2}`);
      if (plan.planned_start_at_utc !== registry.planned_start_at_utc || plan.planned_end_at_utc !== registry.planned_end_at_utc) fail(`${label}: planned dates disagree with experiments.csv`);
      if (plan.planned_sample_per_arm === null) fail(`${label}: active experiment requires planned_sample_per_arm`);
      if (plan.primary_metric?.baseline === null) fail(`${label}: active experiment requires a primary-metric baseline`);
      const absoluteEffect = plan.primary_metric?.minimum_detectable_effect_absolute;
      const relativeEffect = plan.primary_metric?.minimum_detectable_effect_relative;
      if (!((absoluteEffect !== null && absoluteEffect > 0) || (relativeEffect !== null && relativeEffect > 0))) {
        fail(`${label}: active experiment requires a positive minimum detectable effect or equivalence margin`);
      }
      if (metricRows.get(registry.primary_metric)?.availability !== "active") fail(`${label}: active experiment primary metric is not currently available`);
      try {
        execFileSync("git", ["cat-file", "-e", `${registry.preregistered_commit}^{commit}`], { cwd: repositoryRoot, stdio: "ignore" });
        const committedPlan = execFileSync("git", ["show", `${registry.preregistered_commit}:${registry.plan_path}`], { cwd: repositoryRoot, encoding: "utf8" });
        if (committedPlan !== readFileSync(absolutePath, "utf8")) fail(`${label}: current plan differs from preregistered commit ${registry.preregistered_commit}`);
      } catch {
        fail(`${label}: preregistered_commit does not contain the registered plan`);
      }
    }
    if ((registry.status === "completed") !== Boolean(registry.decision && registry.decision_at_utc)) fail(`${label}: completed state and decision fields must be set together`);
    const causalDesign = new Set(["platform_split_test", "randomized_holdout", "aa_test"]);
    if (plan.causal_claim_allowed && !causalDesign.has(plan.design_type)) {
      fail(`${label}: causal_claim_allowed=true requires a randomized design`);
    }
    const armCreativeIds = new Map();
    for (const arm of plan.arms ?? []) {
      if (globalArmIds.has(arm.arm_id)) fail(`${label}: arm_id ${arm.arm_id} is reused by another experiment`);
      globalArmIds.add(arm.arm_id);
      armCreativeIds.set(arm.arm_id, new Set(arm.creative_ids ?? []));
    }
    if (plan.design_type === "aa_test") {
      const signatures = [...armCreativeIds.values()].map((ids) => [...ids].sort().join("|"));
      if (new Set(signatures).size !== 1) fail(`${label}: A/A arms must use identical creative_id sets`);
    }
    const armPublications = publications.filter((publication) => publication.experiment_id === plan.experiment_id);
    for (const publication of armPublications) {
      if (!armCreativeIds.has(publication.arm_id)) fail(`${label}: publication ${publication.publication_id} uses unknown arm_id ${publication.arm_id}`);
      else if (!armCreativeIds.get(publication.arm_id).has(publication.creative_id)) fail(`${label}: publication ${publication.publication_id} creative is not allowed in arm ${publication.arm_id}`);
      if (publication.campaign_id !== plan.campaign_id || publication.audience_id !== plan.audience_id) fail(`${label}: publication ${publication.publication_id} campaign/audience differs from plan`);
    }
    if (["running", "completed"].includes(registry.status)) {
      for (const armId of armCreativeIds.keys()) if (!armPublications.some((publication) => publication.arm_id === armId)) fail(`${label}: ${registry.status} experiment has no publication for arm ${armId}`);
    }
  }
  for (const [index, registry] of result.rows.entries()) {
    if (!plans.has(registry.experiment_id)) fail(`${result.contract.path}:${index + 2}: registered experiment has no plan.json`);
  }
  for (const [index, publication] of publications.entries()) {
    const label = `${contractResults.get("publications").contract.path}:${index + 2}`;
    if (Boolean(publication.experiment_id) !== Boolean(publication.arm_id)) fail(`${label}: experiment_id and arm_id must be supplied together`);
  }
}

function validateIngestionDriveLineage(contractResults) {
  const result = contractResults.get("ingestion_runs");
  if (!result) return;
  const folders = rowsById(contractResults, "drive_folders", "folder_key");
  const isDescendant = (key, ancestor) => {
    const seen = new Set();
    let cursor = key;
    while (cursor && !seen.has(cursor)) {
      if (cursor === ancestor) return true;
      seen.add(cursor);
      cursor = folders.get(cursor)?.parent_key;
    }
    return false;
  };
  const expectedFolder = new Map([
    ["instagram", "performance_instagram"], ["meta_ads", "performance_instagram"],
    ["tiktok", "performance_tiktok"], ["tiktok_ads", "performance_tiktok"],
    ["app_store", "performance_stores"], ["google_play", "performance_stores"],
  ]);
  const driveFileIds = new Set();
  for (const [index, row] of result.rows.entries()) {
    const label = `${result.contract.path}:${index + 2}`;
    if (!isDescendant(row.drive_folder_key, "performance_exports")) fail(`${label}: Drive folder is outside performance_exports lineage`);
    if (expectedFolder.has(row.platform) && row.drive_folder_key !== expectedFolder.get(row.platform)) fail(`${label}: platform=${row.platform} must use ${expectedFolder.get(row.platform)}`);
    if (!row.drive_web_url.includes(row.drive_file_id)) fail(`${label}: drive_web_url does not contain drive_file_id`);
    if (driveFileIds.has(row.drive_file_id)) fail(`${label}: drive_file_id is already used by another ingestion; corrections require a new Drive file`);
    driveFileIds.add(row.drive_file_id);
    if (row.raw_relative_path) {
      if (!row.raw_relative_path.startsWith("marketing/data/raw/")) fail(`${label}: raw_relative_path must stay under marketing/data/raw/`);
      const rawPath = join(repositoryRoot, row.raw_relative_path);
      if (!existsSync(rawPath)) fail(`${label}: raw_relative_path does not exist`);
      else if (sha256(rawPath) !== row.sha256) fail(`${label}: local raw export SHA-256 differs from ingestion registry`);
    }
    if (Date.parse(row.imported_at_utc) < Date.parse(row.exported_at_utc)) fail(`${label}: imported_at_utc is earlier than exported_at_utc`);
  }
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
      failDriveSnapshot(`${result.contract.path}:${index + 2}: snapshot source ${row.source_path} is missing`);
      continue;
    }
    const currentBytes = statSync(absolutePath).size;
    const currentHash = sha256(absolutePath);
    if (String(currentBytes) !== row.bytes) failDriveSnapshot(`${result.contract.path}:${index + 2}: ${row.source_path} byte count changed since Drive upload`);
    if (currentHash !== row.sha256) failDriveSnapshot(`${result.contract.path}:${index + 2}: ${row.source_path} SHA-256 changed since Drive upload`);
    try {
      execFileSync("git", ["cat-file", "-e", `${row.source_git_sha}^{commit}`], { cwd: repositoryRoot, stdio: "ignore" });
    } catch {
      failDriveSnapshot(`${result.contract.path}:${index + 2}: source_git_sha ${row.source_git_sha} is not a local commit`);
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
validatePromptBlockHashes(contracts);
validateCreativePack(contracts);
validateMediaAndCreativeState(contracts);
validateTimelineRanges(contracts);
validatePublicationAudiences(contracts);
validateExperimentLifecycle(contracts);
validateIngestionDriveLineage(contracts);
validateDriveSnapshots(contracts);
validateBinaryIsolation();
validateRegisteredPaths(contracts);

if (counters.experimentPlans === 0) notice("No executable experiment plan is registered yet; the templates remain unvalidated placeholders by design.");
if ((contracts.get("publications")?.rows.length ?? 0) === 0) notice("No publication rows exist yet; performance reporting correctly remains at a zero-data baseline.");

if (failures.length > 0 || driveSnapshotFailures.length > 0) {
  if (failures.length > 0) {
    console.error(`Marketing structural validation failed with ${failures.length} issue${failures.length === 1 ? "" : "s"}:`);
    failures.forEach((message) => console.error(`  - ${message}`));
  } else {
    console.error("Marketing structural validation passed.");
  }
  if (driveSnapshotFailures.length > 0) {
    console.error(`Drive snapshot drift (${driveSnapshotFailures.length} issue${driveSnapshotFailures.length === 1 ? "" : "s"}; refresh the Drive copy and registry together):`);
    driveSnapshotFailures.forEach((message) => console.error(`  - ${message}`));
  }
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
