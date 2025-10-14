// Manual test script for NLP service
import { parseTaskInstruction, getUsageExamples } from './src/services/ai/nlpService.js';

console.log('=== NLP Service Manual Tests ===\n');

// Test 1: Spanish instruction
console.log('Test 1: Spanish instruction with all fields');
const test1 = parseTaskInstruction("Crear una tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes");
console.log('Input:', "Crear una tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes");
console.log('Output:', JSON.stringify(test1, null, 2));
console.log('\n---\n');

// Test 2: English instruction
console.log('Test 2: English instruction');
const test2 = parseTaskInstruction("Fix the login bug with high priority for tomorrow assigned to Maria");
console.log('Input:', "Fix the login bug with high priority for tomorrow assigned to Maria");
console.log('Output:', JSON.stringify(test2, null, 2));
console.log('\n---\n');

// Test 3: Date parsing
console.log('Test 3: Absolute date parsing');
const test3 = parseTaskInstruction("Implementar API de usuarios para el 25 de octubre");
console.log('Input:', "Implementar API de usuarios para el 25 de octubre");
console.log('Output:', JSON.stringify(test3, null, 2));
console.log('\n---\n');

// Test 4: ISO date
console.log('Test 4: ISO date format');
const test4 = parseTaskInstruction("Deploy para 2024-12-31");
console.log('Input:', "Deploy para 2024-12-31");
console.log('Output:', JSON.stringify(test4, null, 2));
console.log('\n---\n');

// Test 5: Priority variations
console.log('Test 5: Priority variations');
const testHigh = parseTaskInstruction("Tarea urgente para hacer algo");
const testMedium = parseTaskInstruction("Tarea normal para hacer algo");
const testLow = parseTaskInstruction("Tarea de baja prioridad para hacer algo");
console.log('High priority:', testHigh.priority, '- Confidence:', testHigh.analysis.priority.confidence);
console.log('Medium priority:', testMedium.priority, '- Confidence:', testMedium.analysis.priority.confidence);
console.log('Low priority:', testLow.priority, '- Confidence:', testLow.analysis.priority.confidence);
console.log('\n---\n');

// Test 6: Usage examples
console.log('Test 6: Usage examples');
const examples = getUsageExamples();
console.log('Spanish examples:', examples.spanish.length);
console.log('English examples:', examples.english.length);
console.log('Mixed examples:', examples.mixed.length);
console.log('\nFirst Spanish example:');
const exampleResult = parseTaskInstruction(examples.spanish[0]);
console.log('Input:', examples.spanish[0]);
console.log('Parsed title:', exampleResult.title);
console.log('Priority:', exampleResult.priority);
console.log('Assignee:', exampleResult.assignee);
console.log('Overall confidence:', exampleResult.analysis.overallConfidence);
console.log('\n---\n');

console.log('=== All tests completed ===');
