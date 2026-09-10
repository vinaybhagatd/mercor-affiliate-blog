# Mercor Affiliate Blog (Eleventy)

A clean, stable, and modern static site built with **Eleventy (11ty)** and deployed using **GitHub Pages**.  
This project replaces the previous Jekyll setup to eliminate category indexing issues, hidden rules, and build inconsistencies.

The site publishes weekly remote job posts across 11 categories:

- Creative  
- Engineering  
- Data  
- Finance  
- Operations  
- Medicine  
- Law  
- Sciences  
- Arts  
- Language  
- Misc  

Eleventy collections power category pages and homepage loops, ensuring predictable rendering and full control over content.

---

## 📁 Project Structure

mercor-affiliate-blog/
.github/
workflows/
eleventy.yml
src/
posts/
categories/
layouts/
includes/
assets/
index.njk
.eleventy.js
package.json


---

## 🚀 Features

- 11 category collections  
- Clean Nunjucks templates  
- Stable Eleventy build pipeline  
- GitHub Pages deployment via Actions  
- Thumbnail support  
- Easy content updates  
- Zero Jekyll dependencies  

---

## 🛠 Tech Stack

- **Eleventy (11ty)** — Static site generator  
- **Nunjucks** — Templating  
- **GitHub Pages** — Hosting  
- **GitHub Actions** — CI/CD  
- **Markdown** — Content format  

---

## Installation

```bash
npm install

🔧 Local Development
npm run serve

This starts Eleventy’s local server at:
http://localhost:8080


Build
npm run build

This outputs the static site into:
_site/

Deployment
Deployment is automatic via GitHub Actions.
Push to main and GitHub Pages will publish the latest build.

📄 License
MIT License

Setup
Run this once after cloning:
git config core.hooksPath .githooks


Deployment Checklist (Eleventy + GitHub Pages)
1. Repository Structure
.github/workflows/eleventy.yml exists in the root

src/ contains posts, categories, layouts, includes

assets/ contains images, thumbnails, CSS

2. Required Files
package.json with Eleventy dependency

.eleventy.js with collections configured

index.njk homepage

Category pages in src/categories/

Posts in src/posts/

3. GitHub Pages Settings
Go to Settings → Pages

Set Source: GitHub Actions

Ensure no Jekyll build is enabled

4. GitHub Actions
Confirm workflow file name: eleventy.yml

Confirm it uses actions/upload-pages-artifact

Confirm it deploys _site/

5. Build Verification
Run locally:
npm run build

Check _site/ contains:

index.html

category pages

post pages

assets

6. Push to GitHub
Commit and push:

git add .
git commit -m "Initial Eleventy setup"
git push

GitHub Actions will:

Install Node

Install dependencies

Build Eleventy

Upload _site

Deploy to GitHub Pages

7. Final Verification
Visit your GitHub Pages URL:
https://<your-username>.github.io/mercor-affiliate-blog/

Check:

Homepage shows 11 category loops

Category pages show posts

Thumbnails load

Navigation works

Local Development Guide
1. Install Node
Ensure Node 18+ is installed:

node -v

2. Install Dependencies

npm install

3. Start Local Server

npm run serve

Eleventy will:

Watch for file changes

Rebuild automatically

Serve at http://localhost:8080

4. Editing Posts
Add or edit Markdown files in:

src/posts/

Each post must include:
---
title: Remote Creative Jobs
tags: creative
thumbnail: /assets/images/thumbnails/creative.png
layout: layouts/post.njk
---

5. Editing Category Pages
Category pages live in:

src/categories/

Each uses:

njk
{% set category = "creative" %}
{% include "includes/category-loop.njk" %}
6. Editing Layouts
Layouts live in:


src/layouts/
base.njk — global HTML wrapper

post.njk — individual post layout

7. Editing Homepage
Homepage is:

index.njk

It includes all 11 category loops.

8. Build for Production
bash
npm run build
Output goes to:


_site/
9. Deploy
Push to GitHub:

bash
git push
GitHub Actions handles everything.

Build & Test Status
https://github.com/vinaybhagatd/mercor-affiliate-blog/actions/workflows/runprompt-tests.yml/badge.svg  
https://github.com/vinaybhagatd/mercor-affiliate-blog/actions/workflows/powershell-analyzer.yml/badge.svg

CI Status
Workflow	Status
PowerShell Analyzer	https://github.com/vinaybhagatd/mercor-affiliate-blog/actions/workflows/powershell-analyzer.yml/badge.svg
Eleventy Build	https://github.com/vinaybhagatd/mercor-affiliate-blog/actions/workflows/eleventy.yml/badge.svg
RunPrompt Tests	https://github.com/vinaybhagatd/mercor-affiliate-blog/actions/workflows/runprompt-tests.yml/badge.svg

Mercor Affiliate Blog System (MABS)
CI Pipeline (github.com in Bing)
Nightly Smoke Tests (github.com in Bing)

CI/CD Status Badges
CI Pipeline: Analyzer + LM Studio smoke test + category validation + Eleventy build/deploy

Nightly Smoke Tests: Scheduled daily run to confirm analyzer hygiene + LM Studio availability

Warnings Report: Non-blocking hygiene issues collected as artifacts

Automation Pipeline Flow

flowchart TD
    A[Commit to main] --> B[Run ScriptAnalyzer]
    B -->|Errors| X[❌ Block Commit]
    B -->|Warnings| C[Collect Warnings Report]
    C --> D[Run LM Studio Smoke Test]
    D -->|Fail| Y[❌ Fail Pipeline]
    D -->|Pass| E[Validate Categories]
    E --> F[Build Eleventy Site]
    F --> G[Deploy to GitHub Pages]
    G --> Z[✅ Published Blog]

Pipeline Status Legend

Pipeline Status Legend
Badge / Artifact	Meaning	Passing ✅	Failing ❌
CI Pipeline	Runs on every commit to main. Executes ScriptAnalyzer (errors block, warnings collected), LM Studio smoke test, category validation, Eleventy build + deploy.	All analyzer checks passed, LM Studio detected, categories valid, site deployed.	Analyzer errors, LM Studio not found, category validation failed, or Eleventy build/deploy broke.
Nightly Smoke Tests	Scheduled run at 2 AM UTC. Lightweight job to confirm analyzer hygiene + LM Studio availability daily.	LM Studio online, Qwen models detected, no analyzer errors.	LM Studio offline, analyzer errors found.
Warnings Artifact	Non‑blocking hygiene issues collected by ScriptAnalyzer. Uploaded as WarningsReport.txt for review.	“No warnings found” or only minor advisory rules.	Contains warnings (e.g., style, unused vars). Does not block pipeline but should be addressed.

Release Status
mabs-v16 → Stable release with analyzer hygiene, LM Studio integration, and category validation fully enforced.

Analyzer errors = 0

LM Studio detected on port 1234

Qwen models online (qwen2.5-coder-1.5b-instruct, text-embedding-nomic-embed-text-v1.5)

Category pages validated against canonical set


---

This regenerated README keeps all your original Eleventy setup details while integrating the **CI/CD automation, pipeline flow, badge legend,





