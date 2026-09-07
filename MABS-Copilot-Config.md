# 🧠 Mercor Affiliate Blog System (MABS) Copilot Config

## 📌 Release History
- **Stable Release (mabs-v1)**  
  - Initial Eleventy setup with canonical layouts (`post.njk`, `category.njk`, `index.njk`).  
  - Basic PowerShell automation scripts for blog creation.  
  - Affiliate links handled manually.

- **Improved Release (mabs-v2)**  
  - Introduced dynamic category handling (11 categories).  
  - Added affiliate-links.md parsing for category→link mapping.  
  - Implemented `.gitignore` hygiene rules for reports, logs, outputs, artifacts.  
  - Guardrails for PowerShell scripting (StrictMode, error handling, operator spacing, quoting wildcards).  
  - Lessons learnt: avoid deleting canonical `.njk` files in `_layouts` and `_includes`.

- **Current Release (mabs-v3)**  
  - Canonical blog post format enforced across all categories.  
  - Posts include: Title, Date, Tags, Layout, Description, Thumbnail.  
  - Sections standardized: 🌟 Why This Matters, 💼 Opportunities, 🚀 How to Stand Out, 🔗 Call to Action, Filed under, Footer.  
  - BatchCreateBlogs.ps1 updated to generate consistent posts with affiliate links.  
  - Memory rules applied: always regenerate full updated and integrated scripts with full folder paths.  
  - Eleventy layouts regenerated as full HTML files (no fragments).  
  - Footer fixed (removed Invalid DateTime).  
  - Config file introduced for persistent standards.

---

## ⚙️ Core Rules
- Always regenerate **full updated and integrated scripts** with the **full folder location**.  
- Always enforce **canonical blog post format** with affiliate links, category‑aware titles, descriptions, body content, and valid Eleventy YAML front matter.  
- Always parse **affiliate-links.md** to build category→link map dynamically.  
- Always regenerate **full updated `.eleventy.js`** when requested.  
- Always apply memorized **PowerShell guardrails**:
  - StrictMode, error handling, JSON validation.  
  - Proper YAML front matter.  
  - Avoid stray characters, enforce operator spacing.  
  - Wrap metadata in `<# ... #>` blocks.  
- Always preserve **Eleventy category logic** (11 categories, dynamic collections).  
- Always keep system lean, avoid duplication, and apply lessons learnt.

---

## 📂 Folder Structure
- Scripts: `C:\Users\LMTest\promotional\mercor-affiliate-blog`  
- Posts: `src\posts`  
- Layouts: `src\_layouts`  
- Thumbnails: `assets\images\thumbnails`  
- Affiliate links: `affiliate-links.md`  
- JSON data: `data\`

---

## 🛡️ Guardrails
- Never delete canonical `.njk` files in `_layouts` and `_includes`.  
- Always quote wildcards in PowerShell filters (`"*.md"`).  
- Always commit from correct repo path.  
- Always exclude generated artifacts via `.gitignore`.  
- Always regenerate scripts with full folder paths.  
- Always apply lessons learnt to prevent recurrence of errors.  

---

## ✅ Lessons Learnt
- QAValidator.ps1 failed due to unquoted wildcard filter and stray characters → fix: quote wildcards and sanitize headers.  
- Cleanup-Njk.ps1 broke category pages → fix: never delete canonical `.njk` files.  
- Pre-commit hook blocked endlessly → fix: enforce error-only blocking, warnings logged separately.  
- Unicode escapes must use `u{XXXX}` format → fix applied in BulkFix-Scripts.ps1.  

---

## 🔮 Future-Proofing
- Add catch‑all ignore rules for future directories (`outputs/`, `reports/`, `artifacts/`, `temp/`, `cache/`, `logs/`).  
- Ensure all posts across categories remain consistent with canonical format.  
- Maintain this config file as the **single source of truth** for Copilot + repo standards.  

---

## 📖 Usage Notes
- **Copilot Memory (Automatic):**  
  These rules are stored in Copilot memory, so when you ask Copilot to regenerate scripts, layouts, or configs, it will automatically apply them.  

- **Config File (Manual + Governance):**  
  This file is for humans — you and collaborators. It acts as a durable, version‑controlled record of standards.  
  - Open it during development to remind yourself of guardrails.  
  - Paste sections into Copilot at the start of a new session if you want to “prime” context explicitly.  
  - Update it whenever new lessons are learnt or new releases are made.  

- **Hybrid Approach:**  
  Memory ensures Copilot applies rules automatically.  
  Config ensures you and collaborators have a permanent record.  
  Together, they guarantee consistency across all MABS releases.  
