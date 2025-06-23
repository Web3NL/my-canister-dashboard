/**
 * A simple hello world function to demonstrate the package structure
 * @param name - The name to greet
 * @returns A greeting message
 */
export function helloWorld(name = 'World'): string {
  return `Hello, ${name}!`;
}
