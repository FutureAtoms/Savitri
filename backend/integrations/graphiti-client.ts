export interface GraphitiEvent {
  name: string;
  payload: any;
}

export class GraphitiClient {
  async sendEvent(event: GraphitiEvent): Promise<void> {
    // This is a mock implementation.
    // In a real implementation, this would send the event to the Graphiti API.
    console.log(`Sending event to Graphiti: ${JSON.stringify(event)}`);
    return Promise.resolve();
  }
} 