/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./internal/handler/templates/**/*.html"],
  // aspectClass() in render.go emits these dynamically per card index, so the
  // JIT scanner can't see them in the templates. Safelist keeps them in the bundle.
  safelist: [
    'aspect-[4/5]',
    'aspect-[4/3]',
    'aspect-[1/1]',
    'aspect-[3/4]',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans:  ['Inter', 'sans-serif'],
        serif: ['"DM Serif Display"', 'serif'],
        mono:  ['"IBM Plex Mono"', 'monospace'],
      },
      colors: {
        primary: '#d97706',
        'primary-hover': '#b45309',
        surface: '#ffffff',
        surface2: '#f5f5f4',
        menu: {
          cream:  '#F9F7F2',
          ink:    '#1A1814',
          clay:   '#C4846A',
          muted:  '#8A8680',
          border: '#E8E4DC',
        },
      },
      animation: {
        'fade-in': 'fadeIn 0.4s ease-out'
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        }
      }
    }
  },
  plugins: [],
}
