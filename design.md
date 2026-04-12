# Everest Design Tokens

<!-- Schema: Google Stitch design.md convention (adopted 2026-04-12) -->
<!-- This file is the canonical source of brand tokens for all Everest Capital content. -->
<!-- Consumed by: Eleventy layouts, Nano Banana Pro image generation, Veo 3 style prompts, -->
<!-- Stitch UI generation, and any future agentic content tool. -->

## Brand

- **Name:** Everest Capital USA
- **Product ecosystem:** BidDeed.AI + ZoneWise.AI
- **Voice:** Direct, technical, high-signal. No filler, no marketing euphemism. Data-first.
- **Pairing rule:** BidDeed.AI is never mentioned without ZoneWise.AI. Foreclosures are never mentioned without tax deeds.

## Colors

```yaml
colors:
  primary:
    navy: "#1E3A5F"         # Dominant brand color — headers, primary CTAs, key accents
    navy_light: "#2A4F7F"   # Hover states, secondary fills
  accent:
    orange: "#F59E0B"       # CTA buttons, key highlights, brand moments
    orange_bright: "#FBBF24" # Hover on orange, focus states
  background:
    base: "#020617"         # Slate-950 — primary dark bg
    raised: "#0A1220"       # Cards, elevated surfaces
    card: "#0F1A2E"         # Inner card bg, code blocks
  border:
    default: "#1E293B"      # Slate-800 — default border
    subtle: "#162035"       # Even subtler border for nested surfaces
  text:
    primary: "#E2E8F0"      # Slate-200 — body text on dark bg
    dim: "#94A3B8"          # Slate-400 — secondary text, captions
    faint: "#64748B"        # Slate-500 — timestamps, meta
  semantic:
    green: "#10B981"        # Success, adopted, verified
    red: "#EF4444"          # Error, rejected, failure
    yellow: "#EAB308"       # Warning, pending, caution
    blue: "#3B82F6"         # Info, links, transcript type
    purple: "#A855F7"       # Score badges, special highlights
```

## Typography

```yaml
fonts:
  display: "Inter"          # Headings, UI
  body: "Inter"             # Body copy
  mono: "JetBrains Mono"    # Code, metadata, metric numbers, eyebrow labels
  
weights:
  regular: 400
  medium: 500
  semibold: 600
  bold: 700
  black: 800

scale:
  # Fluid type scale (clamp-based for responsive sizing)
  hero: "clamp(36px, 6vw, 64px)"      # H1 on hero sections
  h1: "clamp(32px, 5vw, 52px)"        # H1 on content pages
  h2: "22px"                          # H2 section headers
  h3: "18px"                          # H3 subsections
  body: "16px"                        # Default body text
  small: "14px"                       # Captions
  micro: "11px"                       # Eyebrows, meta labels (uppercase)
  
letter_spacing:
  tight: "-0.03em"          # Display headings
  normal: "0"               # Body
  wide: "0.1em"             # Uppercase eyebrows
  wider: "0.18em"           # Section labels
```

## Spacing

```yaml
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  2xl: "48px"
  3xl: "64px"
  4xl: "80px"
  
container:
  narrow: "820px"           # Prose content
  default: "1100px"         # Default page container
  wide: "1200px"            # Wide hub pages
```

## Radii

```yaml
radii:
  none: "0"
  sm: "3px"                 # Pills, small badges
  md: "6px"                 # Cards, buttons
  lg: "8px"                 # Larger cards
  xl: "12px"                # Hero cards, modals
  pill: "100px"             # Fully rounded pills
```

## Motion

```yaml
motion:
  fast: "150ms"             # Hover states, small feedback
  base: "200ms"             # Default transitions
  slow: "300ms"             # Layout shifts, reveals
  
  easing:
    default: "cubic-bezier(0.4, 0, 0.2, 1)"    # Tailwind default
    out: "cubic-bezier(0, 0, 0.2, 1)"          # Ease out
    in: "cubic-bezier(0.4, 0, 1, 1)"           # Ease in
```

## Background atmospherics

```yaml
backgrounds:
  default_gradient: |
    background-image:
      radial-gradient(circle at 15% 10%, rgba(30,58,95,0.25) 0%, transparent 50%),
      radial-gradient(circle at 85% 90%, rgba(245,158,11,0.08) 0%, transparent 50%);
  brand_stripe: "linear-gradient(90deg, #1E3A5F, #F59E0B)"
```

## Imagery (Nano Banana Pro + Imagen 4 + Veo 3 prompt conventions)

When generating images or video with Gemini models, prepend these style constraints to every prompt:

```
STYLE: Premium institutional-grade financial intelligence visuals.
PALETTE: Navy #1E3A5F dominant, warm orange #F59E0B accents, near-black #020617 bg.
MOOD: Confident, data-dense, editorial. Not corporate stock. Not cartoon. Not glossy marketing.
TYPOGRAPHY: Inter sans-serif, JetBrains Mono for data.
COMPOSITION: Generous negative space, asymmetric, grid-aware. Avoid symmetry.
AVOID: Purple gradients, generic AI aesthetics, stock photo people, 
       rainbow colors, cliché "startup" visuals, blue-purple tech clichés.
LIGHTING: Low-key, directional, moody. Dark-mode native.
```

## Accessibility

```yaml
a11y:
  contrast:
    text_on_bg: "16.1:1"        # #E2E8F0 on #020617 — AAA
    orange_on_bg: "8.4:1"       # #F59E0B on #020617 — AAA
    navy_accent: "4.8:1"        # #2A4F7F on #020617 — AA (decorative only)
  min_touch_target: "44px"
  focus_ring: "2px solid #F59E0B"
```

## Voice Prompts (for Gemini TTS / ElevenLabs narration)

```yaml
voices:
  default:
    provider: "gemini_tts"
    voice: "Kore"              # Neutral, authoritative
    speed: 1.0
    stability: 0.75
  narrator:
    provider: "elevenlabs"
    voice_id: "TBD-clone-ariel" # Placeholder for Ariel's cloned voice
    stability: 0.65
    style: 0.4
  public_marketing:
    provider: "gemini_tts"
    voice: "Puck"              # Brighter, more inviting
    speed: 1.05
```

## Attribution

- Schema inspired by Google Stitch `design.md` convention (2026-03, Gemini 3 era)
- House brand sourced from `zonewise-web/globals.css` and `BRAND_COLORS.md`
- Maintained by: Ariel Shapira (Founder, Everest Capital USA)
- Consumers: `everest-content` (Eleventy), `everest-media-gateway` (Gemini API), `everest-cinematic` (video pipeline), `zonewise-web` (Next.js)
