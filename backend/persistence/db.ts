import mongoose from 'mongoose';

export const connectDB = async () => {
  try {
    await mongoose.connect('mongodb://localhost/savitri');
    console.log('MongoDB connected...');
  } catch (err: any) {
    console.error(err.message);
    // Exit process with failure
    process.exit(1);
  }
}; 