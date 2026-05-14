module.exports = {
  content: ["./app/templates/**/*.html", "./app/**/*.py"],
  theme: {
    extend: {
      colors: {
        ink: "#172033",
        paper: "#f7f5ef",
        mint: "#2f9c95",
        coral: "#f06f55",
      },
      fontFamily: {
        sans: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"],
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
