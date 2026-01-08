const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
        mono: ['JetBrains Mono', 'Fira Code', 'Consolas', ...defaultTheme.fontFamily.mono],
      },
      colors: {
        // ===========================================
        // DARK THEME - Professional Corporate
        // Slate-based with blue accent
        // WCAG AA compliant contrast ratios
        // ===========================================

        // Background tones (slate-based)
        dark: {
          base: '#0F172A',      // slate-900 - Deepest background
          surface: '#1E293B',   // slate-800 - Cards, panels
          elevated: '#334155',  // slate-700 - Elevated surfaces, modals
          hover: '#475569',     // slate-600 - Hover states
          border: '#475569',    // slate-600 - Borders, dividers
          'border-light': '#64748B', // slate-500 - Lighter borders
        },

        // Primary palette (corporate blue)
        primary: {
          DEFAULT: '#3B82F6',   // blue-500
          light: '#60A5FA',     // blue-400
          dark: '#2563EB',      // blue-600
          muted: '#1E3A5F',     // Muted blue for backgrounds
          subtle: '#172554',    // Very subtle blue tint
        },

        // Accent color (emerald)
        accent: {
          DEFAULT: '#10B981',   // emerald-500
          light: '#34D399',     // emerald-400
          dark: '#059669',      // emerald-600
          muted: '#064E3B',     // Muted for backgrounds
        },

        // Text colors (high contrast for readability)
        text: {
          primary: '#F1F5F9',    // slate-100 - Primary text
          secondary: '#94A3B8',  // slate-400 - Secondary text
          muted: '#64748B',      // slate-500 - Muted/disabled text
          inverse: '#0F172A',    // Text on light backgrounds
        },

        // Semantic colors (status indicators)
        status: {
          success: '#10B981',    // Green - passed
          error: '#EF4444',      // Red - failed
          warning: '#F59E0B',    // Amber - blocked
          info: '#3B82F6',       // Blue - info
        },

        // ===========================================
        // LIGHT THEME - Clean Corporate
        // White/slate based with blue accent
        // ===========================================
        light: {
          white: '#FFFFFF',
          cream: '#F8FAFC',      // slate-50
          surface: '#F1F5F9',    // slate-100
          border: '#E2E8F0',     // slate-200
          'border-dark': '#CBD5E1', // slate-300
        },

        // Legacy terminal colors for status indicators
        terminal: {
          green: '#10B981',
          amber: '#F59E0B',
          red: '#EF4444',
          'red-bright': '#F87171',
          cyan: '#06B6D4',
          white: '#F1F5F9',
          gray: '#64748B',
          'gray-dark': '#475569',
        },
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      boxShadow: {
        'soft': '0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06)',
        'medium': '0 4px 6px rgba(0, 0, 0, 0.1)',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
