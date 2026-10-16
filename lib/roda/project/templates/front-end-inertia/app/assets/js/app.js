import React from 'react'
import { createInertiaApp } from '@inertiajs/react'
import { createRoot } from 'react-dom/client'

createInertiaApp({
  resolve: name => import(`./inertia/views/${name}.jsx`),
  page: JSON.parse(document.getElementById('app').dataset.page),
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },
})
