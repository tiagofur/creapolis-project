import { 
  parseTaskInstruction, 
  calculateNLPMetrics, 
  getUsageExamples 
} from '../src/services/ai/nlpService.js';

describe('NLP Service', () => {
  describe('parseTaskInstruction', () => {
    test('should parse Spanish instruction with all fields', () => {
      const instruction = "Crear una tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes";
      const result = parseTaskInstruction(instruction);
      
      expect(result).toHaveProperty('title');
      expect(result).toHaveProperty('priority');
      expect(result).toHaveProperty('dueDate');
      expect(result).toHaveProperty('assignee');
      expect(result.title).toContain('diseñar');
      expect(result.priority).toBe('HIGH');
      expect(result.assignee).toBe('Juan');
    });
    
    test('should parse English instruction with all fields', () => {
      const instruction = "Fix the login bug with high priority for tomorrow assigned to Maria";
      const result = parseTaskInstruction(instruction);
      
      expect(result).toHaveProperty('title');
      expect(result).toHaveProperty('priority');
      expect(result).toHaveProperty('dueDate');
      expect(result).toHaveProperty('assignee');
      expect(result.title.toLowerCase()).toContain('login');
      expect(result.priority).toBe('HIGH');
      expect(result.assignee).toBe('Maria');
    });
    
    test('should handle priority extraction', () => {
      const highPriority = parseTaskInstruction("Tarea urgente para hacer algo");
      expect(highPriority.priority).toBe('HIGH');
      
      const mediumPriority = parseTaskInstruction("Tarea normal para hacer algo");
      expect(mediumPriority.priority).toBe('MEDIUM');
      
      const lowPriority = parseTaskInstruction("Tarea de baja prioridad para hacer algo");
      expect(lowPriority.priority).toBe('LOW');
    });
    
    test('should handle date extraction - relative dates', () => {
      const today = parseTaskInstruction("Tarea para hoy");
      const todayDate = new Date();
      expect(today.dueDate.getDate()).toBe(todayDate.getDate());
      
      const tomorrow = parseTaskInstruction("Tarea para mañana");
      const tomorrowDate = new Date();
      tomorrowDate.setDate(tomorrowDate.getDate() + 1);
      expect(tomorrow.dueDate.getDate()).toBe(tomorrowDate.getDate());
    });
    
    test('should handle date extraction - absolute dates', () => {
      const result = parseTaskInstruction("Implementar API para el 25 de octubre");
      expect(result.dueDate.getMonth()).toBe(9); // October is month 9 (0-indexed)
      expect(result.dueDate.getDate()).toBe(25);
    });
    
    test('should handle date extraction - ISO format', () => {
      const result = parseTaskInstruction("Deploy para 2024-12-31");
      expect(result.dueDate.getFullYear()).toBe(2024);
      expect(result.dueDate.getMonth()).toBe(11); // December
      expect(result.dueDate.getDate()).toBe(31);
    });
    
    test('should handle assignee extraction', () => {
      const result1 = parseTaskInstruction("Tarea asignar a Carlos para mañana");
      expect(result1.assignee).toBe('Carlos');
      
      const result2 = parseTaskInstruction("Task assigned to John Smith");
      expect(result2.assignee).toContain('John');
    });
    
    test('should extract category', () => {
      const result = parseTaskInstruction("Implementar API de usuarios");
      expect(result.category).toBeDefined();
      expect(result.analysis.category.confidence).toBeGreaterThan(0);
    });
    
    test('should provide confidence scores', () => {
      const result = parseTaskInstruction("Crear tarea urgente para Juan para mañana");
      expect(result.analysis).toHaveProperty('overallConfidence');
      expect(result.analysis.overallConfidence).toBeGreaterThan(0);
      expect(result.analysis.overallConfidence).toBeLessThanOrEqual(1);
    });
    
    test('should throw error for empty instruction', () => {
      expect(() => parseTaskInstruction('')).toThrow();
      expect(() => parseTaskInstruction('   ')).toThrow();
    });
    
    test('should throw error for too short instruction', () => {
      expect(() => parseTaskInstruction('abc')).toThrow();
    });
    
    test('should handle mixed language instruction', () => {
      const result = parseTaskInstruction("Diseñar UI del dashboard, high priority, due tomorrow");
      expect(result).toHaveProperty('title');
      expect(result.priority).toBe('HIGH');
      expect(result.title.toLowerCase()).toContain('dashboard');
    });
  });
  
  describe('calculateNLPMetrics', () => {
    test('should calculate metrics correctly', () => {
      const samples = [
        {
          instruction: "Tarea urgente para Juan",
          expected: { priority: 'HIGH', assignee: 'Juan' },
          actual: { priority: 'HIGH', assignee: 'Juan' }
        },
        {
          instruction: "Tarea normal",
          expected: { priority: 'MEDIUM' },
          actual: { priority: 'MEDIUM' }
        },
        {
          instruction: "Tarea para María",
          expected: { assignee: 'María' },
          actual: { assignee: 'Maria' } // Should be similar enough
        }
      ];
      
      const metrics = calculateNLPMetrics(samples);
      
      expect(metrics).toHaveProperty('totalSamples');
      expect(metrics.totalSamples).toBe(3);
      expect(metrics).toHaveProperty('fieldAccuracy');
      expect(metrics).toHaveProperty('coverage');
      expect(metrics.fieldAccuracy.priority).toBeGreaterThan(0);
    });
    
    test('should handle empty samples', () => {
      const metrics = calculateNLPMetrics([]);
      expect(metrics.totalSamples).toBe(0);
      expect(metrics.accuracy).toBe(0);
    });
  });
  
  describe('getUsageExamples', () => {
    test('should return usage examples', () => {
      const examples = getUsageExamples();
      
      expect(examples).toHaveProperty('spanish');
      expect(examples).toHaveProperty('english');
      expect(examples).toHaveProperty('mixed');
      expect(Array.isArray(examples.spanish)).toBe(true);
      expect(Array.isArray(examples.english)).toBe(true);
      expect(examples.spanish.length).toBeGreaterThan(0);
      expect(examples.english.length).toBeGreaterThan(0);
    });
  });
});
