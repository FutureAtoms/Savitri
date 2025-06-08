import mongoose, { Document, Schema } from 'mongoose';

export interface IUser extends Document {
  email: string;
  password?: string; // Password might not always be present, e.g., with SSO
  createdAt: Date;
  sessions: mongoose.Schema.Types.ObjectId[];
}

const UserSchema: Schema = new Schema({
  email: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  sessions: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Session',
    },
  ],
});

export default mongoose.model<IUser>('User', UserSchema); 