import { Base64 } from "js-base64";
import type { BirthData, FamilyMember, Gender } from "@/types";

const schemePrefix = "jyotishbaje://family/add?payload=";

export type SharedFamilyProfile = {
  version: 1;
  name: string;
  gender: Gender;
  birth?: BirthData;
};

/**
 * Produces the same versioned, app-scoped exchange envelope on both platforms.
 * Kundali calculations and relationship labels are intentionally not shared:
 * the receiver recalculates the chart locally and chooses their relationship.
 */
export function encodeFamilyProfile(member: FamilyMember): string {
  const profile: SharedFamilyProfile = {
    version: 1,
    name: member.name.trim(),
    gender: member.gender,
    ...(member.birth ? { birth: member.birth } : {})
  };
  return `${schemePrefix}${Base64.encodeURI(JSON.stringify(profile))}`;
}

export function decodeFamilyProfile(rawValue: string): SharedFamilyProfile {
  const raw = rawValue.trim();
  const encoded = raw.startsWith(schemePrefix) ? raw.slice(schemePrefix.length) : raw;
  if (!encoded) throw new Error("missing_payload");
  let value: unknown;
  try {
    value = JSON.parse(Base64.decode(encoded));
  } catch {
    throw new Error("invalid_payload");
  }
  if (!value || typeof value !== "object") throw new Error("invalid_payload");
  const profile = value as Partial<SharedFamilyProfile>;
  if (profile.version !== 1 || typeof profile.name !== "string" || !profile.name.trim()) throw new Error("unsupported_payload");
  if (profile.gender !== "male" && profile.gender !== "female" && profile.gender !== "other") throw new Error("invalid_gender");
  if (profile.birth && !isBirthData(profile.birth)) throw new Error("invalid_birth");
  return { version: 1, name: profile.name.trim(), gender: profile.gender, ...(profile.birth ? { birth: profile.birth } : {}) };
}

function isBirthData(value: unknown): value is BirthData {
  if (!value || typeof value !== "object") return false;
  const birth = value as Partial<BirthData>;
  const place = birth.place as Partial<BirthData["place"]> | undefined;
  return [birth.year, birth.month, birth.day, birth.hour, birth.minute].every(Number.isFinite)
    && typeof birth.timeKnown === "boolean"
    && Boolean(place)
    && typeof place?.name === "string"
    && typeof place?.nameNE === "string"
    && [place?.latitude, place?.longitude, place?.utcOffsetHours].every(Number.isFinite)
    && birth.month! >= 1 && birth.month! <= 12
    && birth.day! >= 1 && birth.day! <= 31
    && birth.hour! >= 0 && birth.hour! <= 23
    && birth.minute! >= 0 && birth.minute! <= 59;
}

export function sameSharedIdentity(member: FamilyMember, profile: SharedFamilyProfile): boolean {
  if (member.name.trim().toLocaleLowerCase() !== profile.name.trim().toLocaleLowerCase()) return false;
  if (!member.birth || !profile.birth) return !member.birth && !profile.birth;
  return member.birth.year === profile.birth.year
    && member.birth.month === profile.birth.month
    && member.birth.day === profile.birth.day;
}
