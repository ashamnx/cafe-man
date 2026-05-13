/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./internal/handler/templates/**/*.html"],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      colors: {
        primary: '#d97706',
        'primary-hover': '#b45309',
        surface: '#ffffff',
        surface2: '#f5f5f4',
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
