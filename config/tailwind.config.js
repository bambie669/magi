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
        // EVA-01 DARK THEME - Professional & Accessible
        // Inspired by EVA-01's purple armor with green accents
        // WCAG AA compliant contrast ratios
        // ===========================================

        // Background tones (dark charcoal with purple undertone)
        dark: {
          base: '#0C0C10',      // Deepest background
          surface: '#13131A',   // Cards, panels
          elevated: '#1A1A24',  // Elevated surfaces, modals
          hover: '#22222E',     // Hover states
          border: '#2A2A3C',    // Borders, dividers
          'border-light': '#363649', // Lighter borders
        },

        // Purple palette (EVA-01 armor - muted, professional)
        eva: {
          purple: {
            DEFAULT: '#6B5B95',  // Primary purple
            light: '#8677AD',    // Lighter purple
            dark: '#524578',     // Darker purple
            muted: '#3D3555',    // Muted purple for backgrounds
            subtle: '#2A2438',   // Very subtle purple tint
          },
          // Green accents (EVA-01 highlights - used sparingly)
          green: {
            DEFAULT: '#4ADE80',  // Primary accent (softer than neon)
            light: '#86EFAC',    // Light accent
            dark: '#22C55E',     // Dark accent
            muted: '#166534',    // Muted for backgrounds
          },
          // Orange (entry plug / warning accent)
          orange: {
            DEFAULT: '#F97316',
            light: '#FB923C',
            dark: '#EA580C',
          },
        },

        // Text colors (high contrast for readability)
        text: {
          primary: '#EAEAF0',    // Primary text - off-white
          secondary: '#A8A8B8',  // Secondary text
          muted: '#6B6B80',      // Muted/disabled text
          inverse: '#13131A',    // Text on light backgrounds
        },

        // Semantic colors (status indicators)
        status: {
          success: '#10B981',    // Green - passed/nominal
          error: '#EF4444',      // Red - failed/breach
          warning: '#F59E0B',    // Amber - blocked/caution
          info: '#3B82F6',       // Blue - info
        },

        // ===========================================
        // EVA-00 LIGHT THEME - Rei's Unit
        // Blue, white, orange accents
        // ===========================================
        eva00: {
          white: '#F8FAFC',
          cream: '#F1F5F9',
          blue: '#0EA5E9',
          'blue-light': '#38BDF8',
          'blue-dark': '#0284C7',
          'blue-pale': '#E0F2FE',
          orange: '#F97316',
          'orange-light': '#FB923C',
          'orange-dark': '#EA580C',
          gray: '#64748B',
          'gray-light': '#94A3B8',
          'gray-dark': '#475569',
        },

        // Legacy aliases for compatibility
        nerv: {
          black: '#0C0C10',
          purple: '#13131A',
          'purple-light': '#1A1A24',
          'purple-mid': '#22222E',
          'purple-glow': '#6B5B95',
        },
        terminal: {
          green: '#4ADE80',
          amber: '#F59E0B',
          red: '#EF4444',
          'red-bright': '#F87171',
          cyan: '#22D3EE',
          white: '#EAEAF0',
          gray: '#6B6B80',
          'gray-dark': '#3A3A4A',
        },
        magi: {
          casper: '#F87171',
          balthasar: '#2DD4BF',
          melchior: '#FBBF24',
        },
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'glow': 'glow 2s ease-in-out infinite alternate',
        'glow-success': 'glow-success 2s ease-in-out infinite alternate',
        'scan': 'scan 8s linear infinite',
      },
      keyframes: {
        glow: {
          '0%': { boxShadow: '0 0 5px rgba(107, 91, 149, 0.3)' },
          '100%': { boxShadow: '0 0 15px rgba(107, 91, 149, 0.5)' },
        },
        'glow-success': {
          '0%': { boxShadow: '0 0 5px rgba(74, 222, 128, 0.2)' },
          '100%': { boxShadow: '0 0 10px rgba(74, 222, 128, 0.4)' },
        },
        scan: {
          '0%': { transform: 'translateY(-100%)' },
          '100%': { transform: 'translateY(100%)' },
        },
      },
      boxShadow: {
        'eva': '0 0 20px rgba(107, 91, 149, 0.2)',
        'eva-strong': '0 0 30px rgba(107, 91, 149, 0.3)',
        'glow-green': '0 0 10px rgba(74, 222, 128, 0.3)',
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
