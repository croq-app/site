/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/js/**/*.js', './src/elm/**/*.elm'],
  theme: {
    extend: {},
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("daisyui")],
}
