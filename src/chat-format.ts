import type { ChatMessage, Language } from "@/types";

export type ChatBlock =
  | { kind: "paragraph"; text: string }
  | { kind: "heading"; text: string }
  | { kind: "bullet"; text: string };

/** Removes presentation syntax before chat copy is reused as a tappable action. */
export function stripChatMarkdown(value: string): string {
  return value
    .replace(/^\s{0,3}#{1,6}\s+/gm, "")
    .replace(/^\s*[-*+]\s+/gm, "")
    .replace(/^\s*\d+[.)]\s+/gm, "")
    .replace(/!\[([^\]]*)\]\([^)]*\)/g, "$1")
    .replace(/\[([^\]]+)\]\([^)]*\)/g, "$1")
    .replace(/(\*\*|__)(.*?)\1/g, "$2")
    .replace(/(\*|_)(.*?)\1/g, "$2")
    .replace(/[`~>]/g, "")
    .replace(/[ \t]+/g, " ")
    .replace(/\s+([?!.।])/g, "$1")
    .trim();
}
export function parseChatBlocks(value: string): ChatBlock[] {
  const blocks: ChatBlock[] = [];
  for (const rawLine of value.replace(/\r/g, "").split("\n")) {
    const line = rawLine.trim();
    if (!line) continue;
    const heading = line.match(/^#{1,6}\s+(.+)$/);
    if (heading) {
      blocks.push({ kind: "heading", text: heading[1].trim() });
      continue;
    }
    const bullet = line.match(/^(?:[-*+]|\d+[.)])\s+(.+)$/);
    if (bullet) {
      blocks.push({ kind: "bullet", text: bullet[1].trim() });
      continue;
    }
    blocks.push({ kind: "paragraph", text: line });
  }
  return blocks;
}

function finalQuestion(value: string): string | undefined {
  const clean = stripChatMarkdown(value);
  if (!clean) return undefined;
  const matches = clean.match(/(?:^|[.!।]\s+)([^.!।]*\?)/g);
  const last = matches?.at(-1)?.replace(/^[.!।]\s+/, "").trim();
  if (last) return last;

  const nepaliPrompt = clean
    .split(/(?<=[।!?])\s+/)
    .reverse()
    .find((part) => /^(?:के|चाहनुहुन्छ|भनूँ|गरूँ)/.test(part.trim()));
  return nepaliPrompt?.trim();
}

/** Suggestions follow the latest answer instead of staying globally static. */
export function chatSuggestions(message: ChatMessage | undefined, language: Language): string[] {
  const defaults = language === "ne"
    ? ["यसलाई अझ सरल भन्नुहोस्", "अब मैले के गर्ने?"]
    : ["Explain this more simply", "What should I do next?"];
  const candidates = [
    ...(message?.suggestedReplies ?? []),
    ...(message?.text ? [finalQuestion(message.text)] : []),
    ...defaults
  ];
  return candidates
    .filter((candidate): candidate is string => Boolean(candidate?.trim()))
    .map(stripChatMarkdown)
    .filter((candidate, index, all) => candidate.length > 0 && all.indexOf(candidate) === index)
    .slice(0, 3);
}
