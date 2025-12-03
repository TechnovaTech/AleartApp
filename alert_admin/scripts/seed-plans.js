const mongoose = require('mongoose');

// MongoDB connection
const MONGODB_URI = 'mongodb://vivekvora:Technova%40990@72.60.30.153:27017/aleartapp?authSource=admin';

const PlanSchema = new mongoose.Schema({
  name: String,
  price: Number,
  duration: String,
  features: [String],
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
});

const Plan = mongoose.model('Plan', PlanSchema);

async function seedPlans() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing plans
    await Plan.deleteMany({});
    console.log('Cleared existing plans');

    // Create default plans
    const plans = [
      {
        name: 'Premium Plan',
        price: 299,
        duration: 'monthly',
        features: [
          'Unlimited SMS monitoring',
          'Real-time notifications',
          'PDF report generation',
          'Multi-language support',
          'Priority customer support',
          'Advanced analytics',
          'QR code management'
        ],
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Annual Premium',
        price: 2999,
        duration: 'yearly',
        features: [
          'All Premium features',
          'Unlimited SMS monitoring',
          'Real-time notifications',
          'PDF report generation',
          'Multi-language support',
          'Priority customer support',
          'Advanced analytics',
          'QR code management',
          '2 months free (Save ₹599)'
        ],
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];

    await Plan.insertMany(plans);
    console.log('✅ Plans seeded successfully!');
    console.log('Created plans:');
    plans.forEach(plan => {
      console.log(`- ${plan.name}: ₹${plan.price}/${plan.duration}`);
    });

  } catch (error) {
    console.error('❌ Error seeding plans:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

seedPlans();