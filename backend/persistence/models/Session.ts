import mongoose, { Document, Schema } from 'mongoose';

export interface ISession extends Document {
  user: mongoose.Schema.Types.ObjectId;
  startTime: Date;
  endTime?: Date;
  interactions: mongoose.Schema.Types.ObjectId[];
}

const SessionSchema: Schema = new Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  startTime: {
    type: Date,
    default: Date.now,
  },
  endTime: {
    type: Date,
  },
  interactions: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Interaction',
    },
  ],
});

export default mongoose.model<ISession>('Session', SessionSchema); 