const React = require('react')

const Link = ({ children, href, ...props }) => React.createElement('a', { href, ...props }, children)

module.exports = {
  Link,
  Head: ({ children }) => React.createElement(React.Fragment, null, children),
  router: { visit: () => {}, get: () => {}, post: () => {}, reload: () => {} },
  usePage: () => ({ props: {}, url: '/', component: '' }),
  useForm: () => ({ data: {}, setData: () => {}, submit: () => {}, processing: false, errors: {} }),
}
