/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/**/*.{js,jsx,ts,tsx}', './components/**/*.{js,jsx,ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        pacte: {
          orange: '#FF8A00',
          cream: '#FDF6E3',
          mint: '#4ADE80',
          dark: '#1E293B',
        },
      },
      borderRadius: {
        '4xl': '32px',
      },
    },
  },
  plugins: [],
};
