# PriceMate Canada - GitHub Pages Setup

## ✅ Files Ready!

The landing page files have been committed to the `docs/` folder and pushed to GitHub.

## 🚀 Enable GitHub Pages (One-Time Setup)

Follow these steps to enable GitHub Pages:

### Step 1: Go to Repository Settings
1. Visit: https://github.com/akaash-nigam/iOS_PriceMateCanada
2. Click on **Settings** tab (top right)

### Step 2: Navigate to Pages
1. In the left sidebar, scroll down to **Pages** under "Code and automation"
2. Click on **Pages**

### Step 3: Configure Source
1. Under **Source**, select:
   - **Branch**: `master` (or `main` if that's your default)
   - **Folder**: `/docs`
2. Click **Save**

### Step 4: Wait for Deployment
- GitHub will automatically build and deploy your site
- This takes 1-2 minutes
- You'll see a green banner with the URL when ready

## 🌐 Your Landing Page URL

Once enabled, your site will be live at:

**https://akaash-nigam.github.io/iOS_PriceMateCanada/**

## ✅ Verify Deployment

After enabling, check:
```bash
# Check deployment status
gh api repos/akaash-nigam/iOS_PriceMateCanada/pages

# Visit the URL
open https://akaash-nigam.github.io/iOS_PriceMateCanada/
```

## 🔧 How to Update

Once GitHub Pages is enabled, updating is simple:

1. **Edit files** in the `docs/` folder
2. **Commit changes**:
   ```bash
   git add docs/
   git commit -m "Update landing page"
   git push origin master
   ```
3. **Wait 1-2 minutes** - changes will be live automatically

## 💰 Cost Comparison

| Platform | Cost | Setup Complexity | Update Process |
|----------|------|------------------|----------------|
| **GitHub Pages** | **FREE** ✅ | One-time click | git push |
| Cloud Run | $2-20/month | Dockerfile + deploy | Build + deploy |

## 🎯 Benefits of GitHub Pages

1. ✅ **100% Free** - Forever
2. ✅ **Fast Global CDN** - Served from edge locations
3. ✅ **Auto HTTPS** - SSL certificate included
4. ✅ **Simple Updates** - Just git push
5. ✅ **No Docker** - No container management
6. ✅ **No Server** - Fully static, no backend needed
7. ✅ **Custom Domain** - Easy to configure (optional)

## 🌐 Optional: Custom Domain

Want to use `pricemate.ca` or `www.pricemate.ca`?

### Step 1: Add Custom Domain in GitHub
1. Go to Settings → Pages
2. Under "Custom domain", enter: `pricemate.ca`
3. Click Save

### Step 2: Configure DNS
Add these DNS records with your domain registrar:

**For apex domain (pricemate.ca):**
```
Type: A
Host: @
Value: 185.199.108.153
Value: 185.199.109.153
Value: 185.199.110.153
Value: 185.199.111.153
```

**For www subdomain (www.pricemate.ca):**
```
Type: CNAME
Host: www
Value: akaash-nigam.github.io
```

**SSL Certificate:**
- GitHub automatically provisions SSL for custom domains
- Takes 24-48 hours after DNS propagation

## 📊 What's Deployed

The `docs/` folder contains:
```
docs/
├── index.html          (25 KB) - Main landing page
├── styles.css          (16 KB) - Styling
├── script.js           (11 KB) - Interactivity
├── assets/             - Images and icons
└── README.md           - Documentation
```

## 🔒 Security

GitHub Pages automatically provides:
- ✅ HTTPS enforcement
- ✅ DDoS protection
- ✅ CDN distribution
- ✅ Access logs (via GitHub Insights)

## 📈 Analytics (Optional)

Add Google Analytics to `docs/index.html`:

```html
<!-- Add before </head> -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

## 🛠️ Troubleshooting

### Issue: Page shows 404
- **Solution**: Ensure GitHub Pages is enabled in Settings → Pages
- **Check**: Verify `docs/index.html` exists in the repository

### Issue: Changes not appearing
- **Solution**: Wait 1-2 minutes after pushing
- **Check**: GitHub Actions tab for build status
- **Clear**: Browser cache (Cmd+Shift+R)

### Issue: Assets not loading
- **Solution**: Ensure paths are relative (not absolute)
- **Check**: `assets/` folder is in `docs/`

## 🎉 Next Steps

Once GitHub Pages is enabled:

1. ✅ **Verify deployment** - Visit the URL
2. 📊 **Add analytics** - Track visitor behavior
3. 🎨 **Update content** - Add real screenshots
4. 🔗 **Share URL** - Use in marketing
5. 🌐 **Custom domain** - Point pricemate.ca (optional)

## 📞 Support

- **GitHub Pages Docs**: https://docs.github.com/pages
- **Repository**: https://github.com/akaash-nigam/iOS_PriceMateCanada
- **Issues**: https://github.com/akaash-nigam/iOS_PriceMateCanada/issues

---

## 🎊 Success!

Your PriceMate Canada landing page is now:
- ✅ Committed to GitHub
- ✅ Ready for GitHub Pages deployment
- ✅ **100% FREE forever**
- ✅ Simple to update (just git push)

**Just enable GitHub Pages in repository settings and you're live!**

---

**Previous deployment**: Google Cloud Run (now can be deleted to save $2-20/month)
**Current deployment**: GitHub Pages (free, fast, simple)

**Created**: December 17, 2024
**Status**: ✅ Ready for GitHub Pages activation
