'use client';

import { useState, useEffect } from 'react';
import { supportService } from '@/lib/support-api';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { UserCheck, UserPlus } from 'lucide-react';

interface SupportAgent {
  id: number;
  name: string;
  email: string;
  avatar: string | null;
}

interface TicketAssignmentProps {
  ticketId: number;
  currentAssignedTo: number | null;
  onAssignmentChange: () => void;
}

export default function TicketAssignment({ ticketId, currentAssignedTo, onAssignmentChange }: TicketAssignmentProps) {
  const [agents, setAgents] = useState<SupportAgent[]>([]);
  const [selectedAgent, setSelectedAgent] = useState<string>(currentAssignedTo?.toString() || 'unassigned');
  const [loading, setLoading] = useState(false);
  const [isLoadingAgents, setIsLoadingAgents] = useState(true);

  const fetchAgents = async () => {
    try {
      setIsLoadingAgents(true);
      const response = await supportService.getSupportAgents();
      setAgents(response.data);
    } catch (error) {
      console.error('Error fetching support agents:', error);
    } finally {
      setIsLoadingAgents(false);
    }
  };

  useEffect(() => {
    fetchAgents();
  }, []);

  const handleAssignment = async () => {
    try {
      setLoading(true);
      const assignedTo = selectedAgent === 'unassigned' ? null : parseInt(selectedAgent);
      await supportService.assignTicket(ticketId, assignedTo);
      onAssignmentChange();
    } catch (error) {
      console.error('Error assigning ticket:', error);
    } finally {
      setLoading(false);
    }
  };

  const currentAgent = agents.find(agent => agent.id === currentAssignedTo);

  return (
    <div className="flex items-center space-x-2">
      <Select value={selectedAgent} onValueChange={setSelectedAgent}>
        <SelectTrigger className="w-[200px]">
          <SelectValue placeholder="Asignar agente">
            {selectedAgent === 'unassigned' ? (
              <div className="flex items-center space-x-2">
                <UserPlus className="h-4 w-4" />
                <span>Sin asignar</span>
              </div>
            ) : (
              currentAgent && (
                <div className="flex items-center space-x-2">
                  <UserCheck className="h-4 w-4" />
                  <span>{currentAgent.name}</span>
                </div>
              )
            )}
          </SelectValue>
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="unassigned">
            <div className="flex items-center space-x-2">
              <UserPlus className="h-4 w-4" />
              <span>Sin asignar</span>
            </div>
          </SelectItem>
          {agents.map((agent) => (
            <SelectItem key={agent.id} value={agent.id.toString()}>
              <div className="flex items-center space-x-2">
                <UserCheck className="h-4 w-4" />
                <div>
                  <div className="font-medium">{agent.name}</div>
                  <div className="text-sm text-gray-500">{agent.email}</div>
                </div>
              </div>
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      <Button 
        onClick={handleAssignment} 
        size="sm" 
        disabled={loading || isLoadingAgents}
      >
        {loading ? 'Asignando...' : 'Asignar'}
      </Button>
    </div>
  );
}