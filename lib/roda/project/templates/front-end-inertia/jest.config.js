module.exports = {
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/app/assets/js/inertia'],
  testMatch: ['**/*.test.js'],
  moduleFileExtensions: ['js', 'jsx', 'json'],
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
}
