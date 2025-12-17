# Assets Directory

Place your images and media files here.

## 📸 Recommended Assets

### App Screenshots

**screenshot-home.png**
- **Size**: 1170 × 2532px (iPhone 14 Pro)
- **Format**: PNG
- **Usage**: Hero section phone mockup
- **Note**: Should show app's main screen

**screenshot-scan.png** (Optional)
- Barcode scanning screen
- For features section

**screenshot-list.png** (Optional)
- Shopping list view
- For features section

**screenshot-compare.png** (Optional)
- Price comparison screen
- For features section

### Logo & Branding

**logo.png** / **logo.svg**
- **Size**: 512 × 512px
- **Format**: PNG with transparency or SVG
- **Usage**: Navigation, footer, social sharing

**favicon.ico**
- **Size**: 32 × 32px
- **Format**: ICO
- **Usage**: Browser tab icon

**app-icon.png**
- **Size**: 1024 × 1024px
- **Format**: PNG
- **Usage**: Download section, social sharing

### Store Logos (Optional)

If you want to replace text with actual logos:
- **loblaws-logo.png**
- **metro-logo.png**
- **walmart-logo.png**
- **costco-logo.png**
- etc.

**Size**: 200 × 200px
**Format**: PNG with transparency

### Social Media

**og-image.png**
- **Size**: 1200 × 630px
- **Usage**: Facebook/LinkedIn sharing
- Should show app mockup + tagline

**twitter-card.png**
- **Size**: 1200 × 600px
- **Usage**: Twitter sharing

### Background Images (Optional)

**hero-bg.jpg**
- **Size**: 1920 × 1080px
- **Format**: JPG (optimized)
- **Usage**: Hero section background

**maple-leaf-pattern.svg**
- Vector pattern of maple leaves
- For decorative backgrounds

## 🎨 Design Guidelines

### Screenshots
- Show real app content, not placeholders
- Use Canadian stores and products
- Display prices in CAD ($)
- Show English or French interface
- Ensure text is readable

### Color Scheme
Match the app's colors:
- Primary: #CC0000 (Canadian Red)
- Secondary: #FFFFFF (White)
- Accent: #1a1a1a (Dark text)

### File Optimization

Before adding images:
1. **Resize** to recommended dimensions
2. **Compress** using tools like:
   - TinyPNG.com
   - ImageOptim (Mac)
   - Squoosh.app
3. **Target size**: <200KB per image

### Formats

- **PNG**: Screenshots, logos, icons
- **JPG**: Photos, backgrounds
- **SVG**: Vector graphics, icons
- **WebP**: Modern format (with fallback)

## 📂 File Structure

```
assets/
├── ASSETS_README.md (this file)
├── screenshots/
│   ├── screenshot-home.png
│   ├── screenshot-scan.png
│   ├── screenshot-list.png
│   └── screenshot-compare.png
├── logos/
│   ├── logo.png
│   ├── logo.svg
│   ├── app-icon.png
│   └── favicon.ico
├── stores/
│   ├── loblaws-logo.png
│   ├── metro-logo.png
│   └── ...
└── social/
    ├── og-image.png
    └── twitter-card.png
```

## 🛠️ Tools for Creating Assets

### Screenshots
- iOS Simulator (Cmd+S to save)
- iPhone physical device
- Screenshot editors: Shottr, CleanShot X

### Image Editing
- Figma (web-based, free)
- Sketch (Mac, paid)
- GIMP (free)
- Photoshop (paid)

### Mockups
- Mockuuups.studio
- Smartmockups.com
- MockUPhone.com

### Optimization
- TinyPNG.com
- ImageOptim (Mac app)
- Squoosh.app (Google)

## 🎯 Priority Order

If you can only add a few assets, prioritize:

1. **screenshot-home.png** - Shows in hero phone mockup
2. **logo.png** - Branding consistency
3. **favicon.ico** - Browser tab icon
4. **og-image.png** - Social media sharing

## 📝 Notes

- All paths in HTML use relative URLs (`assets/filename.png`)
- Images have fallback if not found (won't break page)
- SVG preferred for logos (scales perfectly)
- Optimize all images before upload
- Use descriptive filenames
- Include alt text in HTML for accessibility

## 🚀 Quick Start

### To add screenshot to hero phone:
1. Place image as `screenshot-home.png` in this folder
2. Reload page - it auto-loads!
3. No HTML changes needed

### To add favicon:
1. Create 32×32px icon as `favicon.ico`
2. Add to HTML `<head>`:
```html
<link rel="icon" href="assets/favicon.ico">
```

### To add Open Graph image:
1. Create 1200×630px image as `og-image.png`
2. Add to HTML `<head>`:
```html
<meta property="og:image" content="assets/og-image.png">
```

---

**Need custom assets designed?**

Consider hiring a designer on:
- Fiverr.com
- Upwork.com
- 99designs.com
- Dribbble.com/freelance

Or use AI tools:
- Midjourney (images)
- DALL-E (images)
- Figma AI (designs)

🍁 **Make your landing page shine!** 🍁
