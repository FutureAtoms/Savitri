import mongoose, { Document, Schema } from 'mongoose';
import { EmotionResult, TherapeuticResponse } from '../../clinical/types';

export interface IInteraction extends Document {
  session: mongoose.Schema.Types.ObjectId;
  timestamp: Date;
  userInput: string;
  emotionalState: EmotionResult;
  therapeuticResponse: TherapeuticResponse;
}

const InteractionSchema: Schema = new Schema({
  session: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Session',
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
  userInput: {
    type: String,
    required: true,
  },
  emotionalState: {
    type: Object,
    required: true,
  },
  therapeuticResponse: {
    type: Object,
    required: true,
  },
});

export default mongoose.model<IInteraction>('Interaction', InteractionSchema); 