import React from "react";
import { Switch, View, type LayoutChangeEvent } from "react-native";
import { AppText, Field, Hairline, InfoRow, PressableScale, PrimaryButton, SectionLabel, SerifText } from "../components";
import { ScrollScreen } from "../layout";
import { AppIcon } from "../ornaments";
import { useAppState } from "../app-state";
import { panchangaFor, uuid } from "../astro";
import { digits } from "../l10n";
import { layoutMetrics, palette, spacing } from "../theme";
import type { Language, NepaliDate, PatroEvent } from "../types";

const FIRST_YEAR = 2000;
const MONTHS: Record<Language, string[]> = {
  en: ["Baisakh", "Jestha", "Asar", "Shrawan", "Bhadra", "Asoj", "Kartik", "Mangsir", "Poush", "Magh", "Falgun", "Chait"],
  ne: ["वैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज", "कात्तिक", "मंसिर", "पुष", "माघ", "फागुन", "चैत"]
};
const WEEKDAYS: Record<Language, string[]> = {
  en: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
  ne: ["आइत", "सोम", "मंगल", "बुध", "बिहि", "शुक्र", "शनि"]
};
const TITHI_NAMES: Record<Language, string[]> = {
  en: [
    "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami", "Shashthi", "Saptami", "Ashtami", "Navami", "Dashami",
    "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Purnima", "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami",
    "Shashthi", "Saptami", "Ashtami", "Navami", "Dashami", "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Amavasya"
  ],
  ne: [
    "प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पञ्चमी", "षष्ठी", "सप्तमी", "अष्टमी", "नवमी", "दशमी",
    "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी", "पूर्णिमा", "प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पञ्चमी",
    "षष्ठी", "सप्तमी", "अष्टमी", "नवमी", "दशमी", "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी", "औँसी"
  ]
};

// Exact table shared with BikramSambat.swift (BS 2000–2090).
const BS_MONTH_DAYS: readonly number[][] = [
  [30,32,31,32,31,30,30,30,29,30,29,31],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,31,32,32,31,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,31],
  [30,32,31,32,31,30,30,30,29,30,29,31],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,31,32,32,31,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,31],
  [31,31,31,32,31,31,29,30,30,29,29,31],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,31,32,32,31,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,31],
  [31,31,31,32,31,31,29,30,30,29,30,30],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,31,32,32,31,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,31],
  [31,31,31,32,31,31,29,30,30,29,30,30],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,30,29,31],
  [31,31,31,32,31,31,30,29,30,29,30,30],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,30,29,29,30,30],[31,32,31,32,31,30,30,30,29,30,29,31],
  [31,31,31,32,31,31,30,29,30,29,30,30],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,30,29,29,30,31],[30,32,31,32,31,30,30,30,29,30,29,31],
  [31,31,32,31,31,31,30,29,30,29,30,30],[31,31,32,31,32,30,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,30,29,30,29,31],[30,32,31,32,31,30,30,30,29,30,29,31],
  [31,31,32,31,31,31,30,29,30,29,30,30],[31,31,32,32,31,30,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,30,29,29,30,31],[30,32,31,32,31,31,29,30,30,29,29,31],
  [31,31,32,31,31,31,30,29,30,29,30,30],[31,31,32,32,31,30,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,30,29,29,30,31],[31,31,31,32,31,31,29,30,30,29,30,30],
  [31,31,32,31,31,31,30,29,30,29,30,30],[31,31,32,32,31,30,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,30,29,29,30,31],[31,31,31,32,31,31,29,30,30,29,30,30],
  [31,31,32,31,31,31,30,29,30,29,30,30],[31,32,31,32,31,30,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,30,29,29,30,31],[31,31,31,32,31,31,30,29,30,29,30,30],
  [31,31,32,31,31,31,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,30],
  [31,32,31,32,31,30,30,30,29,30,29,31],[31,31,31,32,31,31,30,29,30,29,30,30],
  [31,31,32,31,31,31,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,30],
  [31,32,31,32,31,30,30,30,29,30,29,31],[31,31,32,31,31,31,30,29,30,30,29,30],
  [31,31,32,31,32,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,30,29,31],
  [30,32,31,32,31,30,30,30,29,30,29,31],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,31,32,32,31,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,31],
  [30,32,31,32,31,31,29,30,29,30,29,31],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,31,32,32,31,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,31],
  [31,31,31,32,31,31,29,30,30,29,29,31],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,31,32,32,31,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,31],
  [31,31,31,32,31,31,29,30,30,29,30,30],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,29,30,29,30,30],[31,32,31,32,31,30,30,30,29,29,30,31],
  [31,31,31,32,31,31,30,29,30,29,30,30],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,30,29,29,30,30],[31,32,31,32,31,30,30,30,29,30,29,31],
  [31,31,31,32,31,31,30,29,30,29,30,30],[31,31,32,31,31,31,30,29,30,29,30,30],
  [31,32,31,32,31,30,30,30,29,29,30,30],[31,31,32,32,31,30,30,30,29,30,30,30],
  [30,32,31,32,31,30,30,30,29,30,30,30],[31,31,32,31,31,30,30,30,29,30,30,30],
  [31,31,32,31,31,30,30,30,29,30,30,30],[31,32,31,32,30,31,30,30,29,30,30,30],
  [30,32,31,32,31,30,30,30,29,30,30,30],[31,31,32,31,31,31,30,30,29,30,30,30],
  [30,31,32,32,30,31,30,30,29,30,30,30],[30,32,31,32,31,30,30,30,29,30,30,30],
  [30,32,31,32,31,30,30,30,29,30,30,30]
];

export function daysInBsMonth(year: number, month: number) {
  return BS_MONTH_DAYS[year - FIRST_YEAR]?.[month - 1] ?? 30;
}

export function bsToAd(bs: NepaliDate) {
  let offset = 0;
  for (let year = FIRST_YEAR; year < bs.year; year += 1) offset += BS_MONTH_DAYS[year - FIRST_YEAR]?.reduce((sum, value) => sum + value, 0) ?? 365;
  for (let month = 1; month < bs.month; month += 1) offset += daysInBsMonth(bs.year, month);
  offset += bs.day - 1;
  const date = new Date(1943, 3, 14, 12, 0, 0, 0);
  date.setDate(date.getDate() + offset);
  return date;
}

export function adToBs(ad: Date): NepaliDate {
  const anchor = new Date(1943, 3, 14, 12, 0, 0, 0);
  const target = new Date(ad.getFullYear(), ad.getMonth(), ad.getDate(), 12, 0, 0, 0);
  let remaining = Math.floor((target.getTime() - anchor.getTime()) / 86_400_000);
  let year = FIRST_YEAR;
  while (year - FIRST_YEAR < BS_MONTH_DAYS.length) {
    const yearDays = BS_MONTH_DAYS[year - FIRST_YEAR].reduce((sum, value) => sum + value, 0);
    if (remaining < yearDays) break;
    remaining -= yearDays;
    year += 1;
  }
  let month = 1;
  while (month < 12 && remaining >= daysInBsMonth(year, month)) {
    remaining -= daysInBsMonth(year, month);
    month += 1;
  }
  return { year, month, day: remaining + 1 };
}

export function PatroScreen() {
  const app = useAppState();
  const today = React.useMemo(() => adToBs(new Date()), []);
  const [shown, setShown] = React.useState<NepaliDate>({ ...today, day: 1 });
  const [selected, setSelected] = React.useState<NepaliDate>();
  const [gridWidth, setGridWidth] = React.useState(0);

  if (selected) {
    return <DayDetail bs={selected} onBack={() => setSelected(undefined)} />;
  }

  const firstWeekday = bsToAd({ ...shown, day: 1 }).getDay();
  const days = daysInBsMonth(shown.year, shown.month);
  const cells = [...Array.from({ length: firstWeekday }, () => 0), ...Array.from({ length: days }, (_, index) => index + 1)];
  const cellWidth = gridWidth > 0 ? (gridWidth - 24) / 7 : 44;
  return (
    <ScrollScreen topInset={8} bottomInset={96} contentGap={16}>
      <View style={styles.header}>
        <SerifText style={styles.title}>{app.language === "ne" ? "नेपाली पात्रो" : "Nepali Patro"}</SerifText>
        <PressableScale accessibilityLabel="Close" onPress={app.closeModal} style={styles.iconButton}>
          <AppIcon name="close" size={20} color={palette.inkSecondary} />
        </PressableScale>
      </View>

      <View style={styles.monthHeader}>
        <PressableScale accessibilityLabel="Previous month" onPress={() => setShown(moveMonth(shown, -1))} style={styles.iconButton}>
          <AppIcon name="chevron-left" size={20} color={palette.saffron} />
        </PressableScale>
        <View style={styles.monthTitle}>
          <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 24 }}>
            {`${MONTHS[app.language][shown.month - 1]} ${digits(shown.year, app.language)}`}
          </SerifText>
        </View>
        <PressableScale accessibilityLabel="Next month" onPress={() => setShown(moveMonth(shown, 1))} style={styles.iconButton}>
          <AppIcon name="chevron-right" size={20} color={palette.saffron} />
        </PressableScale>
      </View>

      <View style={{ gap: 12 }} onLayout={(event: LayoutChangeEvent) => setGridWidth(event.nativeEvent.layout.width)}>
        <View style={{ flexDirection: "row" }}>
          {WEEKDAYS[app.language].map((label, index) => (
            <AppText key={label} style={{ width: `${100 / 7}%`, textAlign: "center", color: index === 6 ? palette.sindoor : palette.inkSecondary, fontFamily: "Inter-SemiBold", fontSize: 12 }}>
              {label}
            </AppText>
          ))}
        </View>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 4 }}>
          {cells.map((day, index) => day === 0 ? (
            <View key={`blank-${index}`} style={{ width: cellWidth, height: 72 }} />
          ) : (
            <DayCell
              key={day}
              bs={{ ...shown, day }}
              width={cellWidth}
              isToday={sameBs(today, { ...shown, day })}
              isSaturday={(firstWeekday + day - 1) % 7 === 6}
              events={app.events}
              language={app.language}
              onPress={() => setSelected({ ...shown, day })}
            />
          ))}
        </View>
      </View>
    </ScrollScreen>
  );
}

function DayCell({ bs, width, isToday, isSaturday, events, language, onPress }: {
  bs: NepaliDate;
  width: number;
  isToday: boolean;
  isSaturday: boolean;
  events: PatroEvent[];
  language: Language;
  onPress: () => void;
}) {
  const pan = panchangaFor(bsToAd(bs), language);
  const tithi = tithiName(pan.tithiNumber, language);
  const hasEvent = events.some((event) => eventOccurs(event, bs));
  return (
    <PressableScale
      accessibilityLabel={`${digits(bs.day, language)} ${MONTHS[language][bs.month - 1]}, ${tithi}`}
      onPress={onPress}
      style={{ width, height: 72, borderRadius: 12, borderCurve: "continuous", backgroundColor: isToday ? palette.bgSunken : "transparent", alignItems: "center", justifyContent: "center", gap: 2, paddingHorizontal: 2 }}
    >
      <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 18, color: isSaturday ? palette.sindoor : palette.inkPrimary }}>{digits(bs.day, language)}</SerifText>
      <AppText numberOfLines={1} adjustsFontSizeToFit minimumFontScale={0.62} style={{ width: "100%", textAlign: "center", color: palette.inkSecondary, fontSize: isToday ? 10 : 11 }}>{tithi}</AppText>
      <View style={{ width: 4, height: 4, borderRadius: 2, backgroundColor: hasEvent ? palette.marigold : "transparent" }} />
    </PressableScale>
  );
}

function DayDetail({ bs, onBack }: { bs: NepaliDate; onBack: () => void }) {
  const app = useAppState();
  const [title, setTitle] = React.useState("");
  const [note, setNote] = React.useState("");
  const [repeats, setRepeats] = React.useState(false);
  const ad = bsToAd(bs);
  const pan = panchangaFor(ad, app.language);
  const dayEvents = app.events.filter((event) => eventOccurs(event, bs));
  const adLabel = ad.toLocaleDateString(app.language === "ne" ? "ne-NP" : "en-US", { weekday: "long", year: "numeric", month: "long", day: "numeric" });
  return (
    <ScrollScreen topInset={8} bottomInset={48} contentGap={20}>
      <View style={styles.header}>
        <PressableScale accessibilityLabel="Back" onPress={onBack} style={{ ...styles.iconButton, marginLeft: -12 }}>
          <AppIcon name="chevron-left" size={21} color={palette.saffron} />
        </PressableScale>
        <View style={{ flex: 1 }} />
        <PressableScale accessibilityLabel="Close" onPress={app.closeModal} style={styles.iconButton}>
          <AppIcon name="close" size={20} color={palette.inkSecondary} />
        </PressableScale>
      </View>

      <View style={{ gap: 4 }}>
        <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 30 }}>
          {`${digits(bs.day, app.language)} ${MONTHS[app.language][bs.month - 1]} ${digits(bs.year, app.language)}`}
        </SerifText>
        <AppText style={{ color: palette.inkSecondary, fontSize: 14 }}>{adLabel}</AppText>
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "पञ्चाङ्ग" : "Panchanga"}</SectionLabel>
        <InfoRow label={app.language === "ne" ? "तिथि" : "Tithi"} value={tithiName(pan.tithiNumber, app.language)} />
        <Hairline />
        <InfoRow label={app.language === "ne" ? "नक्षत्र" : "Nakshatra"} value={pan.nakshatra} />
        <Hairline />
        <InfoRow label={app.language === "ne" ? "योग" : "Yoga"} value={pan.yoga} />
        <Hairline />
        <InfoRow label={app.language === "ne" ? "करण" : "Karana"} value={pan.karana} />
      </View>

      <View style={{ gap: 10 }}>
        <SectionLabel>{app.language === "ne" ? "कार्यक्रमहरू" : "Events"}</SectionLabel>
        {dayEvents.length === 0 ? (
          <AppText style={{ color: palette.inkSecondary }}>{app.language === "ne" ? "यो दिन कुनै कार्यक्रम छैन।" : "No events on this day."}</AppText>
        ) : dayEvents.map((event, index) => (
          <React.Fragment key={event.id}>
            <View style={{ minHeight: 52, flexDirection: "row", gap: 12, alignItems: "center" }}>
              <View style={{ width: 7, height: 7, borderRadius: 4, backgroundColor: palette.marigold }} />
              <View style={{ flex: 1, gap: 2 }}>
                <SerifText style={{ fontFamily: "Fraunces-Bold", fontSize: 17 }}>{event.title}</SerifText>
                {event.note ? <AppText style={{ color: palette.inkSecondary, fontSize: 13 }}>{event.note}</AppText> : null}
              </View>
            </View>
            {index < dayEvents.length - 1 ? <Hairline /> : null}
          </React.Fragment>
        ))}
      </View>

      <View style={{ gap: 12 }}>
        <SectionLabel>{app.language === "ne" ? "कार्यक्रम थप्नुहोस्" : "Add event"}</SectionLabel>
        <Field value={title} onChangeText={setTitle} placeholder={app.language === "ne" ? "शीर्षक" : "Event title"} />
        <Field value={note} onChangeText={setNote} placeholder={app.language === "ne" ? "नोट (ऐच्छिक)" : "Note (optional)"} />
        <View style={{ minHeight: 48, flexDirection: "row", alignItems: "center", justifyContent: "space-between" }}>
          <SerifText style={{ fontSize: 16 }}>{app.language === "ne" ? "हरेक वर्ष दोहोर्याउनुहोस्" : "Repeat every year"}</SerifText>
          <Switch value={repeats} onValueChange={setRepeats} trackColor={{ false: palette.bgSunken, true: palette.saffron }} thumbColor={palette.bgElevated} />
        </View>
        <PrimaryButton
          title={app.language === "ne" ? "कार्यक्रम थप्नुहोस्" : "Add event"}
          disabled={!title.trim()}
          onPress={() => {
            const cleanTitle = title.trim();
            if (!cleanTitle) return;
            app.addEvent({ id: uuid(), title: cleanTitle, note: note.trim(), bsDate: bs, repeatsYearly: repeats });
            setTitle("");
            setNote("");
            setRepeats(false);
          }}
        />
      </View>
    </ScrollScreen>
  );
}

function moveMonth(date: NepaliDate, delta: number): NepaliDate {
  let year = date.year;
  let month = date.month + delta;
  if (month < 1) { month = 12; year -= 1; }
  if (month > 12) { month = 1; year += 1; }
  const lastYear = FIRST_YEAR + BS_MONTH_DAYS.length - 1;
  if (year < FIRST_YEAR) return { year: FIRST_YEAR, month: 1, day: 1 };
  if (year > lastYear) return { year: lastYear, month: 12, day: 1 };
  return { year, month, day: 1 };
}

function eventOccurs(event: PatroEvent, date: NepaliDate) {
  return event.bsDate.month === date.month && event.bsDate.day === date.day && (event.repeatsYearly || event.bsDate.year === date.year);
}

function sameBs(first: NepaliDate, second: NepaliDate) {
  return first.year === second.year && first.month === second.month && first.day === second.day;
}

function tithiName(number: number, language: Language) {
  return TITHI_NAMES[language][Math.max(0, Math.min(29, number - 1))];
}

const styles = {
  header: { minHeight: 48, flexDirection: "row" as const, alignItems: "center" as const, justifyContent: "space-between" as const, gap: spacing.md },
  title: { fontFamily: "Fraunces-Bold", fontSize: 34, flexShrink: 1 },
  iconButton: { width: layoutMetrics.minimumTouchTarget, height: layoutMetrics.minimumTouchTarget, alignItems: "center" as const, justifyContent: "center" as const },
  monthHeader: { minHeight: 56, flexDirection: "row" as const, alignItems: "center" as const, justifyContent: "space-between" as const, marginHorizontal: -12 },
  monthTitle: { minHeight: 44, borderRadius: 22, borderCurve: "continuous" as const, backgroundColor: palette.bgSunken, paddingHorizontal: 18, alignItems: "center" as const, justifyContent: "center" as const }
};
