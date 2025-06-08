import { GraphitiClient, GraphitiEvent } from '../integrations/graphiti-client';

describe('GraphitiClient', () => {
  let graphitiClient: GraphitiClient;

  beforeEach(() => {
    graphitiClient = new GraphitiClient();
  });

  it('should send an event to Graphiti', async () => {
    const event: GraphitiEvent = {
      name: 'test-event',
      payload: {
        foo: 'bar',
      },
    };
    const consoleSpy = jest.spyOn(console, 'log');
    await graphitiClient.sendEvent(event);
    expect(consoleSpy).toHaveBeenCalledWith(`Sending event to Graphiti: ${JSON.stringify(event)}`);
  });
}); 