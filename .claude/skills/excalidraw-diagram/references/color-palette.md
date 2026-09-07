# Color Palette & Brand Style — Be Quarks

**This is the single source of truth for all colors and brand-specific styles.** Everything else in the skill is universal design methodology. This file carries the Be Quarks brand palette.

---

## Brand Tokens

| Token | Hex | Role |
|-------|-----|------|
| Magenta profundo | `#AD1457` | Primary brand color: strokes, titles, primary shapes |
| Magenta vivo | `#D81B60` | Secondary brand accent: highlighted shapes, subtitles |
| Rosa claro | `#F06292` | Tertiary accent: lighter emphasis |
| Fondo rosado | `#FCE7F0` | Light brand fill for shapes and callouts |
| Violeta | `#6F1379` | Brand complement: AI/LLM, special or "different-kind" nodes |
| Texto principal | `#1B1F2A` | Body text, text inside light fills |
| Texto secundario | `#6B7280` | Descriptions, annotations, metadata |
| Líneas / bordes | `#E4E7EC` | Dividers, neutral borders, structural lines |
| Fondo de página | `#EEF0F3` | Neutral page/container background |

### Status Colors (state only)

| State | Hex |
|-------|-----|
| Rojo (error, alerta, fallo) | `#E11D2E` |
| Ámbar (advertencia, pendiente, decisión) | `#E08A00` |
| Verde (éxito, fin, OK) | `#0F9D58` |

**Rule (non-negotiable): magenta is identity, never state.** Magenta/rosa/violeta say "this is Be Quarks" or "this is important". They never mean good/bad/warning. To communicate state, use only red `#E11D2E`, amber `#E08A00` and green `#0F9D58`. Never use magenta as "error" or green as "brand".

---

## Shape Colors (Semantic)

Colors encode meaning, not decoration. Each semantic purpose has a fill/stroke pair.

| Semantic Purpose | Fill | Stroke |
|------------------|------|--------|
| Primary/Neutral | `#FCE7F0` | `#AD1457` |
| Secondary | `#F06292` | `#AD1457` |
| Tertiary | `#FFFFFF` | `#D81B60` |
| Start/Trigger | `#FCE7F0` | `#D81B60` |
| End/Success | `#E6F4EC` | `#0F9D58` |
| Warning/Reset | `#FDF1DC` | `#E08A00` |
| Decision | `#FDF1DC` | `#E08A00` |
| AI/LLM | `#F3E5F5` | `#6F1379` |
| Inactive/Disabled | `#EEF0F3` | `#6B7280` (use dashed stroke) |
| Error | `#FDE2E4` | `#E11D2E` |

**Rules**:
- Always pair a darker stroke with a lighter fill for contrast.
- Success, Warning, Decision and Error rows are the ONLY rows that use status colors. Every other row uses brand or neutral colors.
- The light status fills (`#E6F4EC`, `#FDF1DC`, `#FDE2E4`) are derived tints so text stays readable; the stroke carries the status meaning.

---

## Text Colors (Hierarchy)

Use color on free-floating text to create visual hierarchy without containers.

| Level | Color | Use For |
|-------|-------|---------|
| Title | `#AD1457` | Section headings, major labels |
| Subtitle | `#D81B60` | Subheadings, secondary labels |
| Body/Detail | `#6B7280` | Descriptions, annotations, metadata |
| On light fills | `#1B1F2A` | Text inside light-colored shapes |
| On dark fills | `#FFFFFF` | Text inside dark-colored shapes (`#AD1457`, `#6F1379`, `#F06292`) |

---

## Evidence Artifact Colors

Used for code snippets, data examples, and other concrete evidence inside technical diagrams.

| Artifact | Background | Text Color |
|----------|-----------|------------|
| Code snippet | `#1B1F2A` | Syntax-colored (language-appropriate) |
| JSON/data example | `#1B1F2A` | `#F06292` (rosa claro, brand accent on dark) |

---

## Default Stroke & Line Colors

| Element | Color |
|---------|-------|
| Arrows | Use the stroke color of the source element's semantic purpose (brand arrows: `#AD1457`) |
| Structural lines (dividers, trees, timelines) | Neutral border (`#E4E7EC`) or secondary text (`#6B7280`) |
| Marker dots (fill + stroke) | Magenta profundo (`#AD1457`) |

---

## Background

| Property | Value |
|----------|-------|
| Canvas background | `#FFFFFF` |
| Container / section background (optional) | `#EEF0F3` |
