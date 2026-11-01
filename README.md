# Torres Games

Browser games built with plain HTML5 Canvas and JavaScript. No build step, no dependencies.

## Games

| Folder | Game | Controls |
| --- | --- | --- |
| `jungle-racing/` | The Torres Jungle Racing Game | Arrows or WASD to steer, gas and brake |
| `beach-platformer/` | Martina's Beach Challenge | Arrows or WASD to move, Space to jump, Esc for menu |

`index.html` at the root is the landing page that links to both.

## Running locally

Open `index.html` in any browser, or serve the folder so relative links work the same as on the web:

```bash
npx serve .
```

## Publishing

Live at **https://ettorri.github.io/CGames/**. The site deploys to GitHub Pages automatically on every push to `main` through `.github/workflows/deploy.yml`; the workflow enables Pages on first run, so a fresh fork needs no manual setup.

## Adding a game

1. Create a new folder with an `index.html` inside.
2. Add a card for it in the root `index.html`.
3. Commit and push. It goes live in about a minute.
