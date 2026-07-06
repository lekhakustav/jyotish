# Temple of the Day Schedule - BS 2083 Remainder

Status: planning dataset, not yet canonical app data.

Scope: one Nepal-based temple or sacred site for every Nepal civil day from 2026-07-06 (BS 2083-03-22) through 2027-04-13 (BS 2083-12-30), the end of the current BS/Hindu year used by this app.

Sources and assumptions:
- Tithi, paksha, nakshatra, and BS conversion use the app engine in `Jyotish/Core/Astro/Panchanga.swift` and `Jyotish/Core/Patro/BikramSambat.swift`, generated at Nepal civil days.
- Festival labels were reviewed from Hamro Patro BS 2083 month pages (`/calendar/2083/3` through `/calendar/2083/12`) with the gstack `/browse` skill on 2026-07-06.
- This is a product/content planning list. Before shipping as religiously authoritative content, have a Nepali panchang editor review the tithi cutoff and festival priority for edge cases where the app engine and published patro differ by sunrise rules.

Selection precedence:
1. Named Nepal/Hindu festival overrides generic tithi.
2. Major deity vrata overrides weekday, e.g. Ekadashi -> Vishnu/Narayana, Pradosh -> Shiva, Ashtami/Navaratri -> Devi.
3. Nepal-specific geography wins when available, e.g. Fulpati -> Gorkha Kalika, Vivah Panchami -> Janaki Mandir, Indra Jatra -> Akash Bhairav.
4. If no named event exists, assign by tithi and weekday using stable deterministic fallbacks.

## Temple Catalog

| ID | Temple | Deity/theme | Location |
|---|---|---|---|
| `akasha_bhairav` | Akash Bhairav Temple | Bhairav/Indra Jatra | Kathmandu |
| `ashok_binayak` | Ashok Binayak Temple | Ganesh | Kathmandu |
| `barahakshetra` | Barahakshetra Temple | Varaha avatar/Vishnu | Sunsari |
| `bhadrakali` | Bhadrakali Temple | Bhadrakali | Kathmandu |
| `boudhanath` | Boudhanath Stupa | Full-moon Buddhist devotion | Kathmandu |
| `budhanilkantha` | Budhanilkantha Temple | Narayana/Vishnu | Kathmandu |
| `changu_narayan` | Changu Narayan Temple | Vishnu/Narayana | Bhaktapur |
| `dakshinkali` | Dakshinkali Temple | Kali | Kathmandu |
| `devghat` | Devghat Dham | Sacred confluence | Chitwan/Tanahun |
| `doleshwar` | Doleshwar Mahadev Temple | Shiva | Bhaktapur |
| `gokarneshwar` | Gokarneshwar Mahadev Temple | Shiva/Pitri rites | Kathmandu |
| `gorkha_kalika` | Gorkha Kalika Temple | Bhagwati/Kali | Gorkha |
| `gosaikunda` | Gosaikunda Mahadev | Shiva/Rishi tarpan | Rasuwa |
| `guhyeshwari` | Guhyeshwari Shakti Peeth | Shakti/Parvati | Kathmandu |
| `janaki` | Janaki Mandir | Sita/Rama | Janakpur |
| `janakpur_surya` | Janakpur Ganga Sagar / Surya devotion | Surya | Janakpur |
| `krishna_patan` | Krishna Mandir Patan | Krishna | Lalitpur |
| `mahalaxmi_lagankhel` | Mahalaxmi Temple Lagankhel | Lakshmi | Lalitpur |
| `manakamana` | Manakamana Temple | Bhagwati | Gorkha |
| `matsya_narayan` | Matsya Narayan Temple | Matsya avatar/Vishnu | Kathmandu |
| `muktinath` | Muktinath Temple | Vishnu/Moksha | Mustang |
| `nag_pokhari` | Nag Pokhari | Naga | Kathmandu |
| `pashupatinath` | Pashupatinath Temple | Shiva | Kathmandu |
| `radha_krishna_biratnagar` | Radha Krishna Mandir | Radha Krishna | Biratnagar |
| `saraswati_swayambhu` | Saraswati Temple, Swayambhu | Saraswati | Kathmandu |
| `surya_binayak` | Surya Binayak Temple | Surya/Ganesh | Bhaktapur |
| `swayambhu` | Swayambhunath | Self-arisen sacred hill/stupa | Kathmandu |
| `taleju` | Taleju Bhawani Temple | Taleju/Durga | Kathmandu |

## Daily Schedule

| AD date | BS date | Tithi | Festival/event anchor | Temple | Why this temple |
|---|---|---|---|---|---|
| 2026-07-06 | BS 2083-03-22 (Asar 22) | Krishna Shashthi | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-07-07 | BS 2083-03-23 (Asar 23) | Krishna Saptami | गोरखकाली पूजा | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2026-07-08 | BS 2083-03-24 (Asar 24) | Krishna Ashtami | बुधाष्टमी व्रत | Dakshinkali Temple | Ashtami is a Devi tithi, so Dakshinkali anchors the day. |
| 2026-07-09 | BS 2083-03-25 (Asar 25) | Krishna Navami | Tithi/weekday fallback | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2026-07-10 | BS 2083-03-26 (Asar 26) | Krishna Dashami | योगिनी एकादशी व्रत (स्मार्तहरूको) | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-07-11 | BS 2083-03-27 (Asar 27) | Krishna Dwadashi | योगिनी एकादशी व्रत (वैष्णवहरूको)/विश्व जनसंख्या दिवस | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-07-12 | BS 2083-03-28 (Asar 28) | Krishna Trayodashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-07-13 | BS 2083-03-29 (Asar 29) | Krishna Chaturdashi | भानु जयन्ती | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-07-14 | BS 2083-03-30 (Asar 30) | Krishna Aunsi | Tithi/weekday fallback | Gokarneshwar Mahadev Temple | Aunsi is a dark-moon ancestor and Shiva-remembrance day, anchored at Gokarneshwar. |
| 2026-07-15 | BS 2083-03-31 (Asar 31) | Shukla Pratipada | विश्व युवा दक्षता दिवस | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2026-07-16 | BS 2083-03-32 (Asar 32) | Shukla Dwitiya | Tithi/weekday fallback | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2026-07-17 | BS 2083-04-01 (Shrawan 1) | Shukla Tritiya | साउने सङ्क्रान्ति/लुतो फाल्ने दिन/दक्षिणायन आरम्भ | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2026-07-18 | BS 2083-04-02 (Shrawan 2) | Shukla Panchami | Tithi/weekday fallback | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2026-07-19 | BS 2083-04-03 (Shrawan 3) | Shukla Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-07-20 | BS 2083-04-04 (Shrawan 4) | Shukla Saptami | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-07-21 | BS 2083-04-05 (Shrawan 5) | Shukla Ashtami | सूर्य पूजा | Dakshinkali Temple | Ashtami is a Devi tithi, so Dakshinkali anchors the day. |
| 2026-07-22 | BS 2083-04-06 (Shrawan 6) | Shukla Navami | बुधाष्टमी व्रत/गोरखकाली पूजा | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2026-07-23 | BS 2083-04-07 (Shrawan 7) | Shukla Navami | Tithi/weekday fallback | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2026-07-24 | BS 2083-04-08 (Shrawan 8) | Shukla Dashami | Tithi/weekday fallback | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2026-07-25 | BS 2083-04-09 (Shrawan 9) | Shukla Ekadashi | हरिशयनी एकादशी व्रत (तुलसी रोप्ने)/चतुर्मास व्रत आरम्भ | Budhanilkantha Temple | The Chaturmas Vishnu Ekadashi cycle points to reclining Narayana at Budhanilkantha. |
| 2026-07-26 | BS 2083-04-10 (Shrawan 10) | Shukla Dwadashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-07-27 | BS 2083-04-11 (Shrawan 11) | Shukla Trayodashi | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-07-28 | BS 2083-04-12 (Shrawan 12) | Shukla Chaturdashi | विश्व हेपाटाइटिस दिवस | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2026-07-29 | BS 2083-04-13 (Shrawan 13) | Shukla Purnima | गुरु पुर्णिमा व्रत/व्यास जयन्ती/विश्व बाघ दिवस | Swayambhunath | Purnima favors full-moon pilgrimage and illumination; Swayambhu is the Kathmandu valley anchor. |
| 2026-07-30 | BS 2083-04-14 (Shrawan 14) | Krishna Pratipada | अन्तर्राष्ट्रिय मित्रता दिवस/अन्तर्राष्ट्रिय मानव बेचबिखन विरुद्ध दिवस | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2026-07-31 | BS 2083-04-15 (Shrawan 15) | Krishna Dwitiya | खीर खाने दिन | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2026-08-01 | BS 2083-04-16 (Shrawan 16) | Krishna Tritiya | विश्व स्तनपान सप्ताह प्रारम्भ | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2026-08-02 | BS 2083-04-17 (Shrawan 17) | Krishna Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2026-08-03 | BS 2083-04-18 (Shrawan 18) | Krishna Panchami | बीतक कथा प्रारम्भ | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-08-04 | BS 2083-04-19 (Shrawan 19) | Krishna Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-08-05 | BS 2083-04-20 (Shrawan 20) | Krishna Saptami | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-08-06 | BS 2083-04-21 (Shrawan 21) | Krishna Ashtami | गोरखकाली पूजा | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2026-08-07 | BS 2083-04-22 (Shrawan 22) | Krishna Navami | Tithi/weekday fallback | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2026-08-08 | BS 2083-04-23 (Shrawan 23) | Krishna Dashami | राष्ट्रिय भू संरक्षण दिवस | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2026-08-09 | BS 2083-04-24 (Shrawan 24) | Krishna Ekadashi | कामिका एकादशी व्रत/अन्तर्राष्ट्रिय आदिवासी दिवस | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-08-10 | BS 2083-04-25 (Shrawan 25) | Krishna Dwadashi | सोम प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-08-11 | BS 2083-04-26 (Shrawan 26) | Krishna Chaturdashi | गथांमुगः चःह्रे | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2026-08-12 | BS 2083-04-27 (Shrawan 27) | Krishna Aunsi | अन्तर्राष्ट्रिय युवा दिवस | Gokarneshwar Mahadev Temple | Aunsi is a dark-moon ancestor and Shiva-remembrance day, anchored at Gokarneshwar. |
| 2026-08-13 | BS 2083-04-28 (Shrawan 28) | Shukla Pratipada | गुंला पर्व आरम्भ/विश्व सुलेखन दिवस | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2026-08-14 | BS 2083-04-29 (Shrawan 29) | Shukla Dwitiya | Tithi/weekday fallback | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2026-08-15 | BS 2083-04-30 (Shrawan 30) | Shukla Tritiya | वराह जयन्ती | Barahakshetra Temple | Varaha Jayanti maps to Nepal's major Varaha kshetra at Barahakshetra. |
| 2026-08-16 | BS 2083-04-31 (Shrawan 31) | Shukla Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2026-08-17 | BS 2083-05-01 (Bhadra 1) | Shukla Panchami | नाग पञ्चमी व्रत/थारु गुरिया पर्व/सिंह संक्रान्ति | Nag Pokhari | Nag Panchami belongs to serpent worship, so Nag Pokhari is the most literal Nepal anchor. |
| 2026-08-18 | BS 2083-05-02 (Bhadra 2) | Shukla Shashthi | कल्कि जयन्ती | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-08-19 | BS 2083-05-03 (Bhadra 3) | Shukla Saptami | तुलसीदास जयन्ती/राष्ट्रिय सूचना दिवस/विश्व फोटोग्राफी दिवस | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-08-20 | BS 2083-05-04 (Bhadra 4) | Shukla Ashtami | गोरखकाली पूजा | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2026-08-21 | BS 2083-05-05 (Bhadra 5) | Shukla Navami | Tithi/weekday fallback | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2026-08-22 | BS 2083-05-06 (Bhadra 6) | Shukla Dashami | Tithi/weekday fallback | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2026-08-23 | BS 2083-05-07 (Bhadra 7) | Shukla Ekadashi | पुत्रदा एकादशी व्रत | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-08-24 | BS 2083-05-08 (Bhadra 8) | Shukla Dwadashi | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-08-25 | BS 2083-05-09 (Bhadra 9) | Shukla Dwadashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-08-26 | BS 2083-05-10 (Bhadra 10) | Shukla Trayodashi | Tithi/weekday fallback | Pashupatinath Temple | Trayodashi carries Pradosh/Shiva logic, so Pashupatinath is the natural pick. |
| 2026-08-27 | BS 2083-05-11 (Bhadra 11) | Shukla Chaturdashi | Tithi/weekday fallback | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2026-08-28 | BS 2083-05-12 (Bhadra 12) | Shukla Purnima | जनै पूर्णिमा/रक्षा बन्धन/पूर्णिमा व्रत/क्वाति खाने दिन/ऋषितर्पणी/संस्कृत दिवस | Gosaikunda Mahadev | Janai Purnima and Rishi Tarpani are strongly tied to sacred water and Shiva pilgrimage at Gosaikunda. |
| 2026-08-29 | BS 2083-05-13 (Bhadra 13) | Krishna Pratipada | गाईजात्रा (काठमाडौं उपत्यका बिदा)/विश्व आणविक परिक्षण विरुद्धको दिवस | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2026-08-30 | BS 2083-05-14 (Bhadra 14) | Krishna Dwitiya | रोपाईं जात्रा/विश्व बेपत्ता विरुद्धको दिवस | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2026-08-31 | BS 2083-05-15 (Bhadra 15) | Krishna Tritiya | राष्ट्रिय पुस्तकालय दिवस | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-09-01 | BS 2083-05-16 (Bhadra 16) | Krishna Chaturthi | मंगलचौथी व्रत | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2026-09-02 | BS 2083-05-17 (Bhadra 17) | Krishna Panchami | Tithi/weekday fallback | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2026-09-03 | BS 2083-05-18 (Bhadra 18) | Krishna Saptami | गौरा सप्तमी | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-09-04 | BS 2083-05-19 (Bhadra 19) | Krishna Ashtami | श्रीकृष्ण जन्माष्टमी/गाैरा पर्व/गोरखकाली पूजा/दुर्वाष्टमी | Krishna Mandir Patan | Krishna Janmashtami is assigned to Patan Krishna Mandir, Nepal's iconic Krishna shrine. |
| 2026-09-05 | BS 2083-05-20 (Bhadra 20) | Krishna Navami | विराटनगरमा राधाकृष्ण रथयात्रा/गूङा नवमी/मानव बेचबिखन विरुद्ध राष्ट्रिय दिवस | Radha Krishna Mandir | Radha-Krishna festival logic points to Nepal's well-known Radha Krishna mandir and rath-yatra tradition. |
| 2026-09-06 | BS 2083-05-21 (Bhadra 21) | Krishna Dashami | Tithi/weekday fallback | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2026-09-07 | BS 2083-05-22 (Bhadra 22) | Krishna Ekadashi | अजा एकादशी व्रत/निजामती सेवा दिवस | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-09-08 | BS 2083-05-23 (Bhadra 23) | Krishna Dwadashi | प्रदोष व्रत/जेनजी शहीद दिवस/अन्तर्राष्ट्रिय साक्षरता दिवस/विश्व फिजियोथेरापी दिवस | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-09-09 | BS 2083-05-24 (Bhadra 24) | Krishna Trayodashi | Tithi/weekday fallback | Pashupatinath Temple | Trayodashi carries Pradosh/Shiva logic, so Pashupatinath is the natural pick. |
| 2026-09-10 | BS 2083-05-25 (Bhadra 25) | Krishna Chaturdashi | विश्व आत्महत्या रोकथाम दिवस | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2026-09-11 | BS 2083-05-26 (Bhadra 26) | Krishna Aunsi | कुशे औंसी/बुबाको मुख हेर्ने दिन/मोतीराम भट्ट जन्मजयन्ती | Gokarneshwar Mahadev Temple | Aunsi is a dark-moon ancestor and Shiva-remembrance day, anchored at Gokarneshwar. |
| 2026-09-12 | BS 2083-05-27 (Bhadra 27) | Shukla Pratipada | प्राथमिक उपचार दिवस/गुंला पर्व समाप्ति | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2026-09-13 | BS 2083-05-28 (Bhadra 28) | Shukla Dwitiya | दर खाने दिन | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2026-09-14 | BS 2083-05-29 (Bhadra 29) | Shukla Tritiya | हरितालिका तीज (महिला कर्मचारीहरूलाई मात्र)/गणेश चतुर्थी व्रत/राष्ट्रिय धर्मसभा दिवस/राष्ट्रिय बाल दिवस | Pashupatinath Temple | Teej is a Shiva-Parvati vrata, and Nepali observance centers on Pashupatinath. |
| 2026-09-15 | BS 2083-05-30 (Bhadra 30) | Shukla Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2026-09-16 | BS 2083-05-31 (Bhadra 31) | Shukla Panchami | विश्व ओजोन तह बचाउ दिवस | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2026-09-17 | BS 2083-06-01 (Asoj 1) | Shukla Shashthi | विश्वकर्मा पूजा/कन्या संक्रान्ति/वास्तु दिवस/सूर्य षष्ठी/राष्ट्रिय विज्ञान दिवस/विश्व बिरामी सुरक्षा दिवस | Ashok Binayak Temple | Vishwakarma and vastu themes call for auspicious building and craft beginnings; Ganesh is the conservative temple anchor. |
| 2026-09-18 | BS 2083-06-02 (Asoj 2) | Shukla Saptami | महालक्ष्मी व्रतआरम्भ | Mahalaxmi Temple Lagankhel | Lakshmi and Kojagrat observances map directly to Mahalaxmi worship in the Kathmandu valley. |
| 2026-09-19 | BS 2083-06-03 (Asoj 3) | Shukla Ashtami | संविधान दिवस/राधा जन्मोत्सव/गोरखकाली पूजा | Radha Krishna Mandir | Radha-Krishna festival logic points to Nepal's well-known Radha Krishna mandir and rath-yatra tradition. |
| 2026-09-20 | BS 2083-06-04 (Asoj 4) | Shukla Navami | Tithi/weekday fallback | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2026-09-21 | BS 2083-06-05 (Asoj 5) | Shukla Dashami | विश्व शान्ति दिवस/विश्व अल्जाइमर्स दिवस | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-09-22 | BS 2083-06-06 (Asoj 6) | Shukla Ekadashi | हरिपरिवर्तिनी एकादशी व्रत | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-09-23 | BS 2083-06-07 (Asoj 7) | Shukla Dwadashi | वामन द्वादशी/अन्तर्राष्ट्रिय सांकेतिक भाषा दिवस | Changu Narayan Temple | Dwadashi follows Ekadashi and stays in Vishnu logic, so Changu Narayan is a heritage Narayana anchor. |
| 2026-09-24 | BS 2083-06-08 (Asoj 8) | Shukla Trayodashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-09-25 | BS 2083-06-09 (Asoj 9) | Shukla Chaturdashi | इन्द्रजात्रा (काठमाडौं उपत्यका बिदा)/अनन्त चतुर्दशी व्रत/विश्व फार्मासिस्ट दिवस | Akash Bhairav Temple | Indra Jatra in Kathmandu is closely tied to Akash Bhairav and the old city festival circuit. |
| 2026-09-26 | BS 2083-06-10 (Asoj 10) | Shukla Purnima | चेपाङ चोनाम पर्व/अन्तर्राष्ट्रिय परमाणु हतियार निर्मुल दिवस | Swayambhunath | Purnima favors full-moon pilgrimage and illumination; Swayambhu is the Kathmandu valley anchor. |
| 2026-09-27 | BS 2083-06-11 (Asoj 11) | Krishna Pratipada | सोह्रश्राद्ध प्रारम्भ (प्रतिपदा श्राद्ध)/विश्व पर्यटन दिवस | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-09-28 | BS 2083-06-12 (Asoj 12) | Krishna Dwitiya | द्वितीया श्राद्ध/विश्व रेबिज दिवस/अन्तर्राष्ट्रिय सूचनामा विश्वव्यापी पहुँचको दिवस | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-09-29 | BS 2083-06-13 (Asoj 13) | Krishna Tritiya | तृतीया श्राद्ध/विश्व मुटु दिवस | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-09-30 | BS 2083-06-14 (Asoj 14) | Krishna Chaturthi | चतुर्थी श्राद्ध | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-10-01 | BS 2083-06-15 (Asoj 15) | Krishna Panchami | पञ्चमी श्राद्ध/षष्ठी श्राद्ध/राष्ट्रिय चलचित्र दिवस/अन्तर्राष्ट्रिय  ज्येष्ठ नागरिक दिवस | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-10-02 | BS 2083-06-16 (Asoj 16) | Krishna Shashthi | सप्तमी श्राद्ध/विश्व अहिंसा दिवस/विश्व मुस्कान दिवस | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-10-03 | BS 2083-06-17 (Asoj 17) | Krishna Saptami | अष्टमी श्राद्ध/गोरखकाली पूजा/महालक्ष्मी व्रत समाप्त | Mahalaxmi Temple Lagankhel | Lakshmi and Kojagrat observances map directly to Mahalaxmi worship in the Kathmandu valley. |
| 2026-10-04 | BS 2083-06-18 (Asoj 18) | Krishna Ashtami | नवमी श्राद्ध/जितियापर्व (महिला कर्मचारीहरूलाई मात्र)/विश्व पशु दिवस | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-10-05 | BS 2083-06-19 (Asoj 19) | Krishna Dashami | दशमी श्राद्ध/विश्व शिक्षक दिवस | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-10-06 | BS 2083-06-20 (Asoj 20) | Krishna Ekadashi | इन्दिरा एकादशी व्रत/एकादशी श्राद्ध | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-10-07 | BS 2083-06-21 (Asoj 21) | Krishna Dwadashi | द्वादशी श्राद्ध/मघा श्राद्ध | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-10-08 | BS 2083-06-22 (Asoj 22) | Krishna Trayodashi | प्रदोष व्रत/त्रयोदशी श्राद्ध/विश्व दृष्टि दिवस | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-10-09 | BS 2083-06-23 (Asoj 23) | Krishna Chaturdashi | चतुर्दशी श्राद्ध/विश्व हुलाक दिवस | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-10-10 | BS 2083-06-24 (Asoj 24) | Krishna Aunsi | पितृ विसर्जन/औंसी श्राद्ध/विश्व मानसिक स्वास्थ्य दिवस | Gokarneshwar Mahadev Temple | Pitri and shraddha days map to Gokarneshwar, a major Kathmandu ancestor-rite shrine. |
| 2026-10-11 | BS 2083-06-25 (Asoj 25) | Shukla Pratipada | घटस्थापना व्रत/नवरात्र आरम्भ | Taleju Bhawani Temple | Ghatasthapana begins Navaratri, so Taleju Bhawani is the royal Shakti anchor for the day. |
| 2026-10-12 | BS 2083-06-26 (Asoj 26) | Shukla Dwitiya | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-10-13 | BS 2083-06-27 (Asoj 27) | Shukla Tritiya | अन्तर्राष्ट्रिय प्रकोप जोखिम न्यूनीकरण दिवस | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2026-10-14 | BS 2083-06-28 (Asoj 28) | Shukla Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2026-10-15 | BS 2083-06-29 (Asoj 29) | Shukla Panchami | विश्व हातधुने दिवस/अन्तर्राष्ट्रिय ग्रामीण महिला दिवस | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2026-10-16 | BS 2083-06-30 (Asoj 30) | Shukla Shashthi | विश्व खाद्य दिवस | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-10-17 | BS 2083-07-01 (Kartik 1) | Shukla Shashthi | तुला संक्रान्ति/महाअष्टमी व्रत/कालरात्रि/गोरखकाली पूजा | Dakshinkali Temple | Maha Ashtami and Kalaratri emphasize fierce Devi worship, making Dakshinkali the strongest match. |
| 2026-10-18 | BS 2083-07-02 (Kartik 2) | Shukla Saptami | दशैं बिदा | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-10-19 | BS 2083-07-03 (Kartik 3) | Shukla Ashtami | महानवमी व्रत | Taleju Bhawani Temple | Maha Navami belongs to the high point of Navaratri worship, where Taleju Bhawani is the civic-royal anchor. |
| 2026-10-20 | BS 2083-07-04 (Kartik 4) | Shukla Navami | विजया दशमी/देवी विसर्जन | Gorkha Kalika Temple | Vijaya Dashami marks Durga's victory; Gorkha Kalika gives the day a distinctly Nepali Dashain center. |
| 2026-10-21 | BS 2083-07-05 (Kartik 5) | Shukla Dashami | पापांकुशा एकादशी व्रत | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-10-22 | BS 2083-07-06 (Kartik 6) | Shukla Ekadashi | दशैं बिदा/प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-10-23 | BS 2083-07-07 (Kartik 7) | Shukla Dwadashi | संयुक्त राष्ट्रसंघ दिवस/विश्व विकास सूचना दिवस | Changu Narayan Temple | Dwadashi follows Ekadashi and stays in Vishnu logic, so Changu Narayan is a heritage Narayana anchor. |
| 2026-10-24 | BS 2083-07-08 (Kartik 8) | Shukla Trayodashi | कोजाग्रत व्रत/पूर्णिमा व्रत | Mahalaxmi Temple Lagankhel | Lakshmi and Kojagrat observances map directly to Mahalaxmi worship in the Kathmandu valley. |
| 2026-10-25 | BS 2083-07-09 (Kartik 9) | Shukla Chaturdashi | कार्तिक स्नान आरम्भ/आकाशदीपदान आरम्भ | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2026-10-26 | BS 2083-07-10 (Kartik 10) | Shukla Purnima | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-10-27 | BS 2083-07-11 (Kartik 11) | Krishna Pratipada | Tithi/weekday fallback | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2026-10-28 | BS 2083-07-12 (Kartik 12) | Krishna Tritiya | Tithi/weekday fallback | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2026-10-29 | BS 2083-07-13 (Kartik 13) | Krishna Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2026-10-30 | BS 2083-07-14 (Kartik 14) | Krishna Panchami | विश्व शहरीकरण दिवस | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2026-10-31 | BS 2083-07-15 (Kartik 15) | Krishna Shashthi | रविसप्तमी व्रत | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-11-01 | BS 2083-07-16 (Kartik 16) | Krishna Saptami | राधाष्टमी व्रत/गोरखकाली पूजा | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2026-11-02 | BS 2083-07-17 (Kartik 17) | Krishna Ashtami | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-11-03 | BS 2083-07-18 (Kartik 18) | Krishna Navami | Tithi/weekday fallback | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2026-11-04 | BS 2083-07-19 (Kartik 19) | Krishna Dashami | निम्बार्काचार्य जयन्ती/रमा एकादशी व्रत | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-11-05 | BS 2083-07-20 (Kartik 20) | Krishna Ekadashi | धन त्रयोदशी व्रत (धनतेरस)/प्रदोष व्रत/यमदीपदान आरम्भ | Mahalaxmi Temple Lagankhel | Tihar and Dhanteras lean toward household prosperity and Lakshmi devotion. |
| 2026-11-06 | BS 2083-07-21 (Kartik 21) | Krishna Dwadashi | धनवन्तरी जयन्ती/काग तिहार | Mahalaxmi Temple Lagankhel | Tihar and Dhanteras lean toward household prosperity and Lakshmi devotion. |
| 2026-11-07 | BS 2083-07-22 (Kartik 22) | Krishna Trayodashi | लक्ष्मी पूजा/महाकवि लक्ष्मीप्रसाद देवकोटाको जन्म जयन्ती/कुकुर तिहार/नरक चतुर्दशी/सुखरात्री/विश्व रेडियोग्राफी दिवस | Mahalaxmi Temple Lagankhel | Lakshmi and Kojagrat observances map directly to Mahalaxmi worship in the Kathmandu valley. |
| 2026-11-08 | BS 2083-07-23 (Kartik 23) | Krishna Chaturdashi | तिहार बिदा/गाई पूजा/विश्व स्वतन्त्रता दिवस | Mahalaxmi Temple Lagankhel | Tihar and Dhanteras lean toward household prosperity and Lakshmi devotion. |
| 2026-11-09 | BS 2083-07-24 (Kartik 24) | Krishna Aunsi | गोवर्धन पूजा/म्हपूजा/हलि तिहार/नेपाल सम्वत ११४७ प्रारम्भ/गोरु पूजा/शान्ति र विकासको लागि विश्व विज्ञान दिवस | Mahalaxmi Temple Lagankhel | Tihar and Dhanteras lean toward household prosperity and Lakshmi devotion. |
| 2026-11-10 | BS 2083-07-25 (Kartik 25) | Shukla Pratipada | भाइटीका/किजा पूजा/महागुरु फाल्गुनन्द जयन्ती  (किरात धर्मावलम्बीहरुलाई मात्र) | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2026-11-11 | BS 2083-07-26 (Kartik 26) | Shukla Dwitiya | तिहार बिदा/विश्व निमोनिया दिवस | Mahalaxmi Temple Lagankhel | Tihar and Dhanteras lean toward household prosperity and Lakshmi devotion. |
| 2026-11-12 | BS 2083-07-27 (Kartik 27) | Shukla Tritiya | Tithi/weekday fallback | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2026-11-13 | BS 2083-07-28 (Kartik 28) | Shukla Chaturthi | विश्व मधुमेह दिवस/सांस्कृतिक सम्पत्तिको अवैध ओसारपसार विरुद्धको अन्तर्राष्ट्रिय दिवस | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2026-11-14 | BS 2083-07-29 (Kartik 29) | Shukla Panchami | छठ पर्व | Janakpur Ganga Sagar / Surya devotion | Chhath is Surya worship, and Janakpur's ponds and Tarai observance give it the Nepal anchor. |
| 2026-11-15 | BS 2083-07-30 (Kartik 30) | Shukla Shashthi | अन्तर्राष्ट्रिय सहनशीलता दिवस | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-11-16 | BS 2083-08-01 (Mangsir 1) | Shukla Saptami | वृश्चिक संक्रान्ति/भौमाष्टमी व्रत/गोपाष्टमी व्रत/गोरखकाली पूजा/अन्तर्राष्ट्रिय विद्यार्थी दिवस | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2026-11-17 | BS 2083-08-02 (Mangsir 2) | Shukla Ashtami | कुष्मान्ड नवमी व्रत | Dakshinkali Temple | Ashtami is a Devi tithi, so Dakshinkali anchors the day. |
| 2026-11-18 | BS 2083-08-03 (Mangsir 3) | Shukla Ashtami | विश्व शौचालय दिवस/अन्तर्राष्ट्रिय पुरुष दिवस/विश्व दर्शनशास्त्र दिवस | Dakshinkali Temple | Ashtami is a Devi tithi, so Dakshinkali anchors the day. |
| 2026-11-19 | BS 2083-08-04 (Mangsir 4) | Shukla Navami | हरिबोधिनी एकादशी व्रत/तुलसी बिवाह/विश्व बाल दिवस | Budhanilkantha Temple | The Chaturmas Vishnu Ekadashi cycle points to reclining Narayana at Budhanilkantha. |
| 2026-11-20 | BS 2083-08-05 (Mangsir 5) | Shukla Dashami | विश्व टेलिभिजन दिवस | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2026-11-21 | BS 2083-08-06 (Mangsir 6) | Shukla Ekadashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-11-22 | BS 2083-08-07 (Mangsir 7) | Shukla Trayodashi | बैकुण्ठ चतुर्दशी व्रत | Pashupatinath Temple | Trayodashi carries Pradosh/Shiva logic, so Pashupatinath is the natural pick. |
| 2026-11-23 | BS 2083-08-08 (Mangsir 8) | Shukla Chaturdashi | कार्तिक स्नान समाप्ति/चतुर्मास व्रत समाप्ति/गुरु नानक जयन्ती (सिख धर्मावलम्बीहरुलाई मात्र)/निम्बार्काचार्य जयन्ती/सकिमना पुन्हि | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-11-24 | BS 2083-08-09 (Mangsir 9) | Shukla Purnima | अन्तराष्ट्रिय महिला हिंसा अन्त्य दिवस | Swayambhunath | Purnima favors full-moon pilgrimage and illumination; Swayambhu is the Kathmandu valley anchor. |
| 2026-11-25 | BS 2083-08-10 (Mangsir 10) | Krishna Pratipada | Tithi/weekday fallback | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2026-11-26 | BS 2083-08-11 (Mangsir 11) | Krishna Dwitiya | Tithi/weekday fallback | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2026-11-27 | BS 2083-08-12 (Mangsir 12) | Krishna Tritiya | Tithi/weekday fallback | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2026-11-28 | BS 2083-08-13 (Mangsir 13) | Krishna Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2026-11-29 | BS 2083-08-14 (Mangsir 14) | Krishna Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-11-30 | BS 2083-08-15 (Mangsir 15) | Krishna Saptami | भाैमाष्टमी व्रत/गोरखकाली पूजा/विश्व एड्स दिवस | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2026-12-01 | BS 2083-08-16 (Mangsir 16) | Krishna Ashtami | प्रदोष व्रत/अन्तर्राष्ट्रिय दासता उन्मूलन दिवस | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-12-02 | BS 2083-08-17 (Mangsir 17) | Krishna Navami | अन्तर्राष्ट्रिय अपाङ्ग दिवस (विशेष क्षमता भएका कर्मचारीलाई मात्र) | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2026-12-03 | BS 2083-08-18 (Mangsir 18) | Krishna Dashami | उँधौली पर्व/उत्पतिका एकादशी व्रत | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2026-12-04 | BS 2083-08-19 (Mangsir 19) | Krishna Ekadashi | अन्तर्राष्ट्रिय स्वयंसेवक दिवस/विश्व माटो दिवस | Budhanilkantha Temple | Ekadashi is Vishnu-focused; Budhanilkantha gives the day a clear Nepali Narayana anchor. |
| 2026-12-05 | BS 2083-08-20 (Mangsir 20) | Krishna Dwadashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-12-06 | BS 2083-08-21 (Mangsir 21) | Krishna Trayodashi | बाला चतुर्दशी व्रत/शतबीज छर्ने दिन/अन्तर्राष्ट्रिय नागरिक उड्डयन दिवस | Pashupatinath Temple | Trayodashi carries Pradosh/Shiva logic, so Pashupatinath is the natural pick. |
| 2026-12-07 | BS 2083-08-22 (Mangsir 22) | Krishna Chaturdashi | अन्तर्राष्ट्रिय मर्यादित महिनावारी दिवस | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-12-08 | BS 2083-08-23 (Mangsir 23) | Krishna Aunsi | अन्तर्राष्ट्रिय भ्रष्टाचार विरुद्ध दिवस | Gokarneshwar Mahadev Temple | Aunsi is a dark-moon ancestor and Shiva-remembrance day, anchored at Gokarneshwar. |
| 2026-12-09 | BS 2083-08-24 (Mangsir 24) | Krishna Aunsi | अन्तर्राष्ट्रिय मानव अधिकार दिवस | Gokarneshwar Mahadev Temple | Aunsi is a dark-moon ancestor and Shiva-remembrance day, anchored at Gokarneshwar. |
| 2026-12-10 | BS 2083-08-25 (Mangsir 25) | Shukla Pratipada | अन्तर्राष्ट्रिय पर्वत दिवस | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2026-12-11 | BS 2083-08-26 (Mangsir 26) | Shukla Dwitiya | अन्तर्राष्ट्रिय तटस्थ दिवस | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2026-12-12 | BS 2083-08-27 (Mangsir 27) | Shukla Tritiya | Tithi/weekday fallback | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2026-12-13 | BS 2083-08-28 (Mangsir 28) | Shukla Chaturthi | विवाह पञ्चमी/षडानन्द जयन्ती | Janaki Mandir | Vivah Panchami and Sita/Rama logic point directly to Janaki Mandir in Janakpur. |
| 2026-12-14 | BS 2083-08-29 (Mangsir 29) | Shukla Panchami | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-12-15 | BS 2083-08-30 (Mangsir 30) | Shukla Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-12-16 | BS 2083-09-01 (Poush 1) | Shukla Saptami | धनु संक्रान्ति | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-12-17 | BS 2083-09-02 (Poush 2) | Shukla Ashtami | गोरखकाली पूजा | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2026-12-18 | BS 2083-09-03 (Poush 3) | Shukla Navami | अन्तर्राष्ट्रिय आप्रवासी दिवस | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2026-12-19 | BS 2083-09-04 (Poush 4) | Shukla Dashami | Tithi/weekday fallback | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2026-12-20 | BS 2083-09-05 (Poush 5) | Shukla Ekadashi | मोक्षदा एकादशी व्रत/गीता जयन्ती | Muktinath Temple | Mokshada Ekadashi and Gita Jayanti are liberation/Vishnu themes, matched to Muktinath. |
| 2026-12-21 | BS 2083-09-06 (Poush 6) | Shukla Dwadashi | सोम प्रदोष व्रत/विश्व ध्यान दिवस | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2026-12-22 | BS 2083-09-07 (Poush 7) | Shukla Trayodashi | Tithi/weekday fallback | Pashupatinath Temple | Trayodashi carries Pradosh/Shiva logic, so Pashupatinath is the natural pick. |
| 2026-12-23 | BS 2083-09-08 (Poush 8) | Shukla Chaturdashi | दत्तात्रेय जयन्ती | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2026-12-24 | BS 2083-09-09 (Poush 9) | Shukla Purnima | धान्यपुर्णिमा/उधौली पर्व/य:मरि पुन्हि/ज्यापु दिवस | Swayambhunath | Purnima favors full-moon pilgrimage and illumination; Swayambhu is the Kathmandu valley anchor. |
| 2026-12-25 | BS 2083-09-10 (Poush 10) | Krishna Dwitiya | क्रिसमस-डे | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2026-12-26 | BS 2083-09-11 (Poush 11) | Krishna Tritiya | Tithi/weekday fallback | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2026-12-27 | BS 2083-09-12 (Poush 12) | Krishna Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2026-12-28 | BS 2083-09-13 (Poush 13) | Krishna Panchami | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2026-12-29 | BS 2083-09-14 (Poush 14) | Krishna Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-12-30 | BS 2083-09-15 (Poush 15) | Krishna Saptami | तमु ल्होसार/कवि शिरोमणि लेखनाथ जयन्ती | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2026-12-31 | BS 2083-09-16 (Poush 16) | Krishna Ashtami | गोरखकाली पूजा | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2027-01-01 | BS 2083-09-17 (Poush 17) | Krishna Navami | नयाँ वर्ष २०२७ प्रारम्भ/राष्ट्रिय पोशाक दिवस/टोपी दिवस | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2027-01-02 | BS 2083-09-18 (Poush 18) | Krishna Dashami | Tithi/weekday fallback | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2027-01-03 | BS 2083-09-19 (Poush 19) | Krishna Ekadashi | सफला एकादशी व्रत | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2027-01-04 | BS 2083-09-20 (Poush 20) | Krishna Dwadashi | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-01-05 | BS 2083-09-21 (Poush 21) | Krishna Trayodashi | गुरु गोबिन्द सिंह जयन्ती/प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2027-01-06 | BS 2083-09-22 (Poush 22) | Krishna Chaturdashi | Tithi/weekday fallback | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2027-01-07 | BS 2083-09-23 (Poush 23) | Krishna Aunsi | अरनिको स्मृति दिवस | Gokarneshwar Mahadev Temple | Aunsi is a dark-moon ancestor and Shiva-remembrance day, anchored at Gokarneshwar. |
| 2027-01-08 | BS 2083-09-24 (Poush 24) | Shukla Pratipada | तोल ल्होसार/नेपाल ज्योतिष परिषद स्थापना दिवस | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2027-01-09 | BS 2083-09-25 (Poush 25) | Shukla Dwitiya | Tithi/weekday fallback | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2027-01-10 | BS 2083-09-26 (Poush 26) | Shukla Dwitiya | Tithi/weekday fallback | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2027-01-11 | BS 2083-09-27 (Poush 27) | Shukla Tritiya | पृथ्वी जयन्ती/राष्ट्रिय एकता दिवस | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-01-12 | BS 2083-09-28 (Poush 28) | Shukla Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2027-01-13 | BS 2083-09-29 (Poush 29) | Shukla Panchami | राष्ट्रिय भाक्का दिवस | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2027-01-14 | BS 2083-10-01 (Magh 1) | Shukla Shashthi | माघे संक्रान्ति/मकर स्नान आरम्भ/घ्यु चाकु खाने दिन/उत्तरायण आरम्भ | Devghat Dham | Maghe Sankranti and ritual bathing are best anchored at Devghat Dham. |
| 2027-01-15 | BS 2083-10-02 (Magh 2) | Shukla Saptami | राष्ट्रिय भुकम्प सुरक्षा दिवस | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2027-01-16 | BS 2083-10-03 (Magh 3) | Shukla Ashtami | Tithi/weekday fallback | Dakshinkali Temple | Ashtami is a Devi tithi, so Dakshinkali anchors the day. |
| 2027-01-17 | BS 2083-10-04 (Magh 4) | Shukla Navami | पुत्रदा एकादशी व्रत (स्मार्तहरूको लागि) | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2027-01-18 | BS 2083-10-05 (Magh 5) | Shukla Dashami | पुत्रदा एकादशी व्रत (वैष्णवहरूको लागि) | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2027-01-19 | BS 2083-10-06 (Magh 6) | Shukla Ekadashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2027-01-20 | BS 2083-10-07 (Magh 7) | Shukla Trayodashi | Tithi/weekday fallback | Pashupatinath Temple | Trayodashi carries Pradosh/Shiva logic, so Pashupatinath is the natural pick. |
| 2027-01-21 | BS 2083-10-08 (Magh 8) | Shukla Chaturdashi | श्री स्वस्थानी व्रत कथा प्रारम्भ/माघ स्नान सुरु | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2027-01-22 | BS 2083-10-09 (Magh 9) | Shukla Purnima | Tithi/weekday fallback | Swayambhunath | Purnima favors full-moon pilgrimage and illumination; Swayambhu is the Kathmandu valley anchor. |
| 2027-01-23 | BS 2083-10-10 (Magh 10) | Krishna Pratipada | Tithi/weekday fallback | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2027-01-24 | BS 2083-10-11 (Magh 11) | Krishna Dwitiya | Tithi/weekday fallback | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2027-01-25 | BS 2083-10-12 (Magh 12) | Krishna Tritiya | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-01-26 | BS 2083-10-13 (Magh 13) | Krishna Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2027-01-27 | BS 2083-10-14 (Magh 14) | Krishna Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2027-01-28 | BS 2083-10-15 (Magh 15) | Krishna Saptami | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2027-01-29 | BS 2083-10-16 (Magh 16) | Krishna Ashtami | शहीद दिवस | Dakshinkali Temple | Ashtami is a Devi tithi, so Dakshinkali anchors the day. |
| 2027-01-30 | BS 2083-10-17 (Magh 17) | Krishna Navami | विश्व कुष्ठरोग दिवस | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2027-01-31 | BS 2083-10-18 (Magh 18) | Krishna Navami | Tithi/weekday fallback | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2027-02-01 | BS 2083-10-19 (Magh 19) | Krishna Dashami | षट्तिला एकादशी/विश्व सिमसार दिवस | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2027-02-02 | BS 2083-10-20 (Magh 20) | Krishna Ekadashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2027-02-03 | BS 2083-10-21 (Magh 21) | Krishna Dwadashi | विश्व क्यान्सर दिवस | Changu Narayan Temple | Dwadashi follows Ekadashi and stays in Vishnu logic, so Changu Narayan is a heritage Narayana anchor. |
| 2027-02-04 | BS 2083-10-22 (Magh 22) | Krishna Trayodashi | Tithi/weekday fallback | Pashupatinath Temple | Trayodashi carries Pradosh/Shiva logic, so Pashupatinath is the natural pick. |
| 2027-02-05 | BS 2083-10-23 (Magh 23) | Krishna Chaturdashi | Tithi/weekday fallback | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2027-02-06 | BS 2083-10-24 (Magh 24) | Krishna Aunsi | सोनाम ल्होछार | Gokarneshwar Mahadev Temple | Aunsi is a dark-moon ancestor and Shiva-remembrance day, anchored at Gokarneshwar. |
| 2027-02-07 | BS 2083-10-25 (Magh 25) | Shukla Pratipada | Tithi/weekday fallback | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2027-02-08 | BS 2083-10-26 (Magh 26) | Shukla Dwitiya | सुरक्षित इन्टरनेट दिवस | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-02-09 | BS 2083-10-27 (Magh 27) | Shukla Tritiya | तिलकुन्द चौथी | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2027-02-10 | BS 2083-10-28 (Magh 28) | Shukla Chaturthi | वसन्तपञ्चमी व्रत/सरस्वती पूजा | Saraswati Temple, Swayambhu | Basanta Panchami is Saraswati Puja, so the Swayambhu Saraswati shrine is the literal match. |
| 2027-02-11 | BS 2083-10-29 (Magh 29) | Shukla Panchami | स्कन्द षष्ठी | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2027-02-12 | BS 2083-10-30 (Magh 30) | Shukla Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2027-02-13 | BS 2083-11-01 (Falgun 1) | Shukla Saptami | कुम्भ संक्रान्ति/अचला सप्तमी/विश्व रेडियो दिवस | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2027-02-14 | BS 2083-11-02 (Falgun 2) | Shukla Ashtami | गोरखकाली पूजा/प्रणय दिवस | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2027-02-15 | BS 2083-11-03 (Falgun 3) | Shukla Navami | द्रोण नवमी | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-02-16 | BS 2083-11-04 (Falgun 4) | Shukla Dashami | Tithi/weekday fallback | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2027-02-17 | BS 2083-11-05 (Falgun 5) | Shukla Ekadashi | भीमा एकादशी व्रत | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2027-02-18 | BS 2083-11-06 (Falgun 6) | Shukla Dwadashi | भिष्म द्वादशी/प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2027-02-19 | BS 2083-11-07 (Falgun 7) | Shukla Trayodashi | प्रजातन्त्र दिवस/निर्वाचन दिवस | Pashupatinath Temple | Trayodashi carries Pradosh/Shiva logic, so Pashupatinath is the natural pick. |
| 2027-02-20 | BS 2083-11-08 (Falgun 8) | Shukla Chaturdashi | माघ स्नान समाप्ती/सामाजिक न्याय दिवस/श्री स्वस्थानी व्रत समाप्ती/पशुपतिनाथको छाया दर्शन | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2027-02-21 | BS 2083-11-09 (Falgun 9) | Krishna Pratipada | अन्तर्राष्ट्रिय मातृभाषा दिवस | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2027-02-22 | BS 2083-11-10 (Falgun 10) | Krishna Dwitiya | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-02-23 | BS 2083-11-11 (Falgun 11) | Krishna Tritiya | Tithi/weekday fallback | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2027-02-24 | BS 2083-11-12 (Falgun 12) | Krishna Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2027-02-25 | BS 2083-11-13 (Falgun 13) | Krishna Panchami | Tithi/weekday fallback | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2027-02-26 | BS 2083-11-14 (Falgun 14) | Krishna Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2027-02-27 | BS 2083-11-15 (Falgun 15) | Krishna Saptami | विश्व गैरसरकारी संस्था दिवस | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2027-02-28 | BS 2083-11-16 (Falgun 16) | Krishna Ashtami | गोरखकाली पूजा | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2027-03-01 | BS 2083-11-17 (Falgun 17) | Krishna Navami | शून्य भेदभाव दिवस | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-03-02 | BS 2083-11-18 (Falgun 18) | Krishna Dashami | माझी समुदायको लदीपूजा | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2027-03-03 | BS 2083-11-19 (Falgun 19) | Krishna Ekadashi | विश्व वन्यजन्तु दिवस | Budhanilkantha Temple | Ekadashi is Vishnu-focused; Budhanilkantha gives the day a clear Nepali Narayana anchor. |
| 2027-03-04 | BS 2083-11-20 (Falgun 20) | Krishna Ekadashi | विजया एकादशी व्रत | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2027-03-05 | BS 2083-11-21 (Falgun 21) | Krishna Dwadashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2027-03-06 | BS 2083-11-22 (Falgun 22) | Krishna Trayodashi | महाशिवरात्रि/नेपाली सेना दिवस/सिलाचःह्रे पूजा | Pashupatinath Temple | Mahashivaratri and Krishna Chaturdashi point directly to Shiva worship; Pashupatinath is Nepal's primary Shiva shrine. |
| 2027-03-07 | BS 2083-11-23 (Falgun 23) | Krishna Chaturdashi | Tithi/weekday fallback | Doleshwar Mahadev Temple | Chaturdashi is close to Shiva vrata logic; Doleshwar gives a second Nepal Shiva anchor. |
| 2027-03-08 | BS 2083-11-24 (Falgun 24) | Krishna Aunsi | अन्तर्राष्ट्रिय नारी दिवस | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-03-09 | BS 2083-11-25 (Falgun 25) | Shukla Pratipada | ग्याल्पो ल्होसार | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2027-03-10 | BS 2083-11-26 (Falgun 26) | Shukla Dwitiya | Tithi/weekday fallback | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2027-03-11 | BS 2083-11-27 (Falgun 27) | Shukla Tritiya | Tithi/weekday fallback | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2027-03-12 | BS 2083-11-28 (Falgun 28) | Shukla Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2027-03-13 | BS 2083-11-29 (Falgun 29) | Shukla Panchami | Tithi/weekday fallback | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2027-03-14 | BS 2083-11-30 (Falgun 30) | Shukla Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2027-03-15 | BS 2083-12-01 (Chait 1) | Shukla Saptami | मीन संक्रान्ति/विश्व उपभोक्ता अधिकार दिवस | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-03-16 | BS 2083-12-02 (Chait 2) | Shukla Ashtami | गोरखकाली पूजा/भौमाष्टमी व्रत | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2027-03-17 | BS 2083-12-03 (Chait 3) | Shukla Navami | Tithi/weekday fallback | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2027-03-18 | BS 2083-12-04 (Chait 4) | Shukla Ekadashi | आमलकी एकादशी व्रत | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2027-03-19 | BS 2083-12-05 (Chait 5) | Shukla Dwadashi | Tithi/weekday fallback | Changu Narayan Temple | Dwadashi follows Ekadashi and stays in Vishnu logic, so Changu Narayan is a heritage Narayana anchor. |
| 2027-03-20 | BS 2083-12-06 (Chait 6) | Shukla Trayodashi | शनि प्रदोष व्रत/विश्व मुख स्वास्थ्य दिवस/अन्तर्राष्ट्रिय खुशी दिवस | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2027-03-21 | BS 2083-12-07 (Chait 7) | Shukla Chaturdashi | फागु पुर्णिमा (पहाडी जिल्ला)/विश्व कविता दिवस | Krishna Mandir Patan | Fagu Purnima/Holi has strong Krishna-rasa logic; Krishna Mandir Patan keeps it temple-based. |
| 2027-03-22 | BS 2083-12-08 (Chait 8) | Shukla Purnima | फागु पुर्णिमा (तराइ होली)/विश्व जल दिवस | Krishna Mandir Patan | Fagu Purnima/Holi has strong Krishna-rasa logic; Krishna Mandir Patan keeps it temple-based. |
| 2027-03-23 | BS 2083-12-09 (Chait 9) | Krishna Pratipada | तेल लगाउने र आँपको मुजुरा खाने दिन/गणगौर पूजा प्रारम्भ/विश्व मौसम विज्ञान दिवस | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2027-03-24 | BS 2083-12-10 (Chait 10) | Krishna Dwitiya | विश्व क्षयरोग दिवस | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2027-03-25 | BS 2083-12-11 (Chait 11) | Krishna Tritiya | Tithi/weekday fallback | Guhyeshwari Shakti Peeth | Tritiya often leans toward Gauri/Devi vrata logic, so Guhyeshwari is the fallback. |
| 2027-03-26 | BS 2083-12-12 (Chait 12) | Krishna Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2027-03-27 | BS 2083-12-13 (Chait 13) | Krishna Panchami | विश्व रङ्गमञ्च दिवस | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2027-03-28 | BS 2083-12-14 (Chait 14) | Krishna Shashthi | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |
| 2027-03-29 | BS 2083-12-15 (Chait 15) | Krishna Saptami | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-03-30 | BS 2083-12-16 (Chait 16) | Krishna Ashtami | भौमाष्टमी व्रत/गोरखकाली पूजा | Gorkha Kalika Temple | The calendar explicitly marks Gorkhakali Puja, so the day goes to Gorkha Kalika. |
| 2027-03-31 | BS 2083-12-17 (Chait 17) | Krishna Navami | Tithi/weekday fallback | Taleju Bhawani Temple | Navami is kept in Shakti/Durga logic with Taleju Bhawani. |
| 2027-04-01 | BS 2083-12-18 (Chait 18) | Krishna Dashami | विश्व मूर्ख दिवस | Gorkha Kalika Temple | Dashami carries victory and Durga logic, so Gorkha Kalika is the Nepal anchor. |
| 2027-04-02 | BS 2083-12-19 (Chait 19) | Krishna Ekadashi | पापमोचनी एकादशी व्रत/विश्व अटिजम जागरुकता दिवस | Budhanilkantha Temple | Ekadashi is a Vishnu vrata, so Budhanilkantha is the default Nepal Narayana anchor. |
| 2027-04-03 | BS 2083-12-20 (Chait 20) | Krishna Dwadashi | Tithi/weekday fallback | Changu Narayan Temple | Dwadashi follows Ekadashi and stays in Vishnu logic, so Changu Narayan is a heritage Narayana anchor. |
| 2027-04-04 | BS 2083-12-21 (Chait 21) | Krishna Trayodashi | प्रदोष व्रत | Pashupatinath Temple | Pradosh is a Shiva vrata observed around Trayodashi; Pashupatinath is the default Nepal Shiva anchor. |
| 2027-04-05 | BS 2083-12-22 (Chait 22) | Krishna Chaturdashi | Tithi/weekday fallback | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-04-06 | BS 2083-12-23 (Chait 23) | Krishna Chaturdashi | घोडेजात्रा (काठमाडौं उपत्यका बिदा) | Bhadrakali Temple | Ghodajatra happens around Tundikhel; Bhadrakali is the adjacent protective Shakti anchor. |
| 2027-04-07 | BS 2083-12-24 (Chait 24) | Shukla Pratipada | तेल लगाउने र नीमको पात खाने दिन/ज्योतिष दिवस/विश्व स्वास्थ्य दिवस | Changu Narayan Temple | Pratipada opens a fresh lunar phase, anchored by Changu Narayan for auspicious continuity. |
| 2027-04-08 | BS 2083-12-25 (Chait 25) | Shukla Dwitiya | Tithi/weekday fallback | Manakamana Temple | Dwitiya is a quieter household-sankalpa day, so Manakamana fits the wish/prayer logic. |
| 2027-04-09 | BS 2083-12-26 (Chait 26) | Shukla Tritiya | गौरी व्रत/मत्स्य जयन्ती व्रत | Guhyeshwari Shakti Peeth | Gauri vrata is a Parvati/Shakti day, so Guhyeshwari is the strongest Nepal shrine match. |
| 2027-04-10 | BS 2083-12-27 (Chait 27) | Shukla Chaturthi | Tithi/weekday fallback | Ashok Binayak Temple | Chaturthi belongs to Ganesh worship, so Ashok Binayak is the daily temple. |
| 2027-04-11 | BS 2083-12-28 (Chait 28) | Shukla Panchami | Tithi/weekday fallback | Nag Pokhari | Panchami often carries naga/serpent associations, so Nag Pokhari is the conservative fallback. |
| 2027-04-12 | BS 2083-12-29 (Chait 29) | Shukla Shashthi | विश्व ज्योतिष स्थापना दिवस/अन्तर्राष्ट्रिय मानव अन्तरिक्ष उडान दिवस | Pashupatinath Temple | It is Monday, the weekly Shiva day, so Pashupatinath overrides the neutral tithi fallback. |
| 2027-04-13 | BS 2083-12-30 (Chait 30) | Shukla Saptami | Tithi/weekday fallback | Surya Binayak Temple | Shashthi/Saptami carry solar and protective vrata logic; Surya Binayak is the local anchor. |

Rows: 282.
