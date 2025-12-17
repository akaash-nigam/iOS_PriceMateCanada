# 🚀 Quick Start Guide - PriceMate Canada Landing Page

Get your landing page up and running in 2 minutes!

## Option 1: Open Directly (Fastest)

Simply double-click `index.html` in Finder - it will open in your default browser!

## Option 2: Local Server (Recommended)

### Using Python (Pre-installed on Mac)

```bash
# Navigate to the landing page directory
cd landing-page

# Start server
python3 -m http.server 8000

# Open in browser
open http://localhost:8000
```

### Using Node.js

```bash
# If you have Node.js installed
npx serve

# Then open the URL shown in terminal
```

## ✅ What to Check

Once the page loads, verify these features work:

### 1. Navigation
- [ ] Click navigation links (Features, How It Works, etc.)
- [ ] Smooth scroll to sections
- [ ] Mobile menu button (resize browser to <768px)

### 2. Hero Section
- [ ] Animated badge slides down
- [ ] Title and subtitle fade in
- [ ] Stats display correctly ($247, 12+, 100%)
- [ ] Floating cards pulse
- [ ] Phone mockup visible

### 3. Features Section
- [ ] 9 feature cards display in grid
- [ ] Cards lift on hover
- [ ] Featured card has red gradient
- [ ] Icons render properly

### 4. How It Works
- [ ] 3 steps display horizontally
- [ ] Arrows connect steps
- [ ] Emojis show (📱 💰 🎉)

### 5. Stores Section
- [ ] 12 store names in grid
- [ ] Store logos shake on hover
- [ ] Color changes to red on hover

### 6. Testimonials
- [ ] 3 testimonial cards
- [ ] Stars show (⭐⭐⭐⭐⭐)
- [ ] Author avatars display

### 7. Download Section
- [ ] Red gradient background
- [ ] 3D phone showcase visible
- [ ] Phone rotates on mouse move
- [ ] App Store button present

### 8. Footer
- [ ] Logo and links display
- [ ] 4 columns of links
- [ ] Copyright notice at bottom

### 9. Mobile Responsiveness
Resize browser to test:
- **Desktop (1200px+)**: 3-column grids
- **Tablet (768px)**: 2-column grids
- **Mobile (<768px)**: Single column, hamburger menu

## 🎨 Customization Quick Tips

### Change Primary Color
Edit `styles.css` line 15:
```css
--canadian-red: #CC0000;  /* Change to your color */
```

### Update Hero Title
Edit `index.html` line 76:
```html
<h1 class="hero-title">
    Your New Title<br>
    <span class="gradient-text">Goes Here</span>
</h1>
```

### Add App Store Link
Edit `index.html` line 440:
```html
<a href="YOUR_APP_STORE_URL" class="app-store-btn">
```

### Replace Phone Screenshot
1. Place image in `assets/screenshot-home.png`
2. It will auto-load in phone mockup

## 🐛 Troubleshooting

### Images Not Loading
- Check `assets/` folder exists
- Verify image filename matches HTML
- Use relative paths, not absolute

### Animations Not Working
- Clear browser cache (Cmd+Shift+R)
- Check JavaScript console for errors
- Ensure JavaScript is enabled

### Mobile Menu Not Opening
- Check browser console
- Verify `script.js` is loaded
- Test in different browser

### Hover Effects Not Working
- Ensure CSS is loaded
- Check for browser extensions blocking styles
- Try in private/incognito window

## 🎯 Next Steps

1. **Add Screenshots**
   - Take screenshots of your iOS app
   - Save as `assets/screenshot-home.png`
   - Recommended size: 1170 × 2532px (iPhone 14 Pro)

2. **Update App Store Link**
   - Get your App Store URL after submission
   - Update all download buttons

3. **Customize Content**
   - Replace testimonials with real users
   - Update stats with actual data
   - Add your company info to footer

4. **Deploy Online**
   - Upload to web host
   - Point domain to files
   - Configure SSL certificate

## 🌐 Deployment Options

### Option 1: Netlify (Free)
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy
```

### Option 2: GitHub Pages (Free)
```bash
# Push to GitHub
git init
git add .
git commit -m "Initial landing page"
git push origin main

# Enable GitHub Pages in repo settings
```

### Option 3: Vercel (Free)
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel
```

## 📸 Taking Screenshots

### For Hero Phone Mockup
1. Run your iOS app in simulator
2. Take screenshot (Cmd+S in Simulator)
3. Crop to iPhone size (1170 × 2532px)
4. Save as `assets/screenshot-home.png`

### For Additional Sections
- Feature screenshots: 800 × 1200px
- Store logos: 200 × 200px SVG/PNG
- Icons: 48 × 48px

## 🎨 Design Tools

- **Figma**: Design custom graphics
- **Canva**: Create social media images
- **Sketch**: Design app mockups
- **Adobe XD**: Prototype interactions

## 📈 Analytics Setup

### Google Analytics
Add before `</head>` in `index.html`:
```html
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

### Plausible (Privacy-friendly)
```html
<script defer data-domain="yourdomain.com" src="https://plausible.io/js/script.js"></script>
```

## 🔍 SEO Checklist

- [ ] Add meta description
- [ ] Set Open Graph tags
- [ ] Add Twitter Card tags
- [ ] Create `robots.txt`
- [ ] Add `sitemap.xml`
- [ ] Set canonical URL
- [ ] Add structured data (JSON-LD)

## 💡 Easter Egg

Try the **Konami Code** on the live page:
```
↑ ↑ ↓ ↓ ← → ← → B A
```
Watch the maple leaves rain! 🍁

## 📞 Need Help?

- **Issue**: Something not working?
  - Check browser console (F12 → Console)
  - Look for JavaScript errors

- **Question**: How to customize?
  - See `README.md` for detailed docs
  - Check `VISUAL_GUIDE.md` for layout

- **Bug Report**: Found a problem?
  - Note browser and version
  - Describe steps to reproduce
  - Include console errors

## ✨ Pro Tips

1. **Performance**: Images should be <200KB each
2. **SEO**: Update meta tags before going live
3. **Testing**: Test on real devices, not just desktop
4. **Backup**: Keep a copy before making changes
5. **Version Control**: Use Git to track changes

---

**Ready to launch?** 🚀

Open `index.html` in your browser and see your landing page come to life!

🍁 **Happy Launching!** 🍁
