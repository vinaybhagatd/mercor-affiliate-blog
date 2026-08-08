\# Mercor Affiliate Blog (Eleventy)



A clean, stable, and modern static site built with \*\*Eleventy (11ty)\*\* and deployed using \*\*GitHub Pages\*\*.  

This project replaces the previous Jekyll setup to eliminate category indexing issues, hidden rules, and build inconsistencies.



The site publishes weekly remote job posts across 11 categories:



\- Creative  

\- Engineering  

\- Data  

\- Finance  

\- Operations  

\- Medicine  

\- Law  

\- Sciences  

\- Arts  

\- Language  

\- Misc  



Eleventy collections power category pages and homepage loops, ensuring predictable rendering and full control over content.



\---



\## 📁 Project Structure

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

## 📦 Installation

```bash
npm install

🔧 Local Development
bash
npm run serve
This starts Eleventy’s local server at:
Code
http://localhost:8080
🏗 Build
bash
npm run build
This outputs the static site into:
Code
_site/
🚀 Deployment
Deployment is automatic via GitHub Actions. Push to main and GitHub Pages will publish the latest build.
📄 License
MIT License

---

### Setup
Run this once after cloning:
```powershell
git config core.hooksPath .githooks

---

# 🧭 **Deployment Checklist (Eleventy + GitHub Pages)**

### **1. Repository Structure**
- `.github/workflows/eleventy.yml` exists in the **root**  
- `src/` contains posts, categories, layouts, includes  
- `assets/` contains images, thumbnails, CSS  

### **2. Required Files**
- `package.json` with Eleventy dependency  
- `.eleventy.js` with collections configured  
- `index.njk` homepage  
- Category pages in `src/categories/`  
- Posts in `src/posts/`  

### **3. GitHub Pages Settings**
- Go to **Settings → Pages**  
- Set **Source: GitHub Actions**  
- Ensure no Jekyll build is enabled  

### **4. GitHub Actions**
- Confirm workflow file name: `eleventy.yml`  
- Confirm it uses `actions/upload-pages-artifact`  
- Confirm it deploys `_site/`  

### **5. Build Verification**
Run locally:

```bash
npm run build
Check _site/ contains:
•	index.html
•	category pages
•	post pages
•	assets
6. Push to GitHub
Commit and push:
bash
git add .
git commit -m "Initial Eleventy setup"
git push
GitHub Actions will:
1.	Install Node
2.	Install dependencies
3.	Build Eleventy
4.	Upload _site
5.	Deploy to GitHub Pages
7. Final Verification
Visit your GitHub Pages URL:
Code
https://<your-username>.github.io/mercor-affiliate-blog/
Check:
•	Homepage shows 11 category loops
•	Category pages show posts
•	Thumbnails load
•	Navigation works
🖥 Local Development Guide
1. Install Node
Ensure Node 18+ is installed:
bash
node -v
2. Install Dependencies
bash
npm install
3. Start Local Server
bash
npm run serve
Eleventy will:
•	Watch for file changes
•	Rebuild automatically
•	Serve at http://localhost:8080
4. Editing Posts
Add or edit Markdown files in:
Code
src/posts/
Each post must include:
yaml
---
title: Remote Creative Jobs
tags: creative
thumbnail: /assets/images/thumbnails/creative.png
layout: layouts/post.njk
---
5. Editing Category Pages
Category pages live in:
Code
src/categories/
Each uses:
njk
{% set category = "creative" %}
{% include "includes/category-loop.njk" %}
6. Editing Layouts
Layouts live in:
Code
src/layouts/
•	base.njk — global HTML wrapper
•	post.njk — individual post layout
7. Editing Homepage
Homepage is:
Code
index.njk
It includes all 11 category loops.
8. Build for Production
bash
npm run build
Output goes to:
Code
_site/
9. Deploy
Push to GitHub:
bash
git push
GitHub Actions handles everything.

Test




