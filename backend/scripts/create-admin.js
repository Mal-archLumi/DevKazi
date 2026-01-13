// scripts/create-admin.js - UPDATED FOR 'test' DATABASE
const mongoose = require('mongoose');
const bcryptjs = require('bcryptjs');

async function createAdmin() {
  console.log('🚀 Creating SUPER_ADMIN user in TEST database...');
  
  // Use 'test' database instead of 'devkazi'
  const mongoUri = 'mongodb+srv://makutualvine_db_user:lFFomf9pWKI8jJwU@cluster0.slqqzms.mongodb.net/test?retryWrites=true&w=majority&appName=Cluster0';
  
  try {
    console.log('🔗 Connecting to MongoDB...');
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB (test database)');
    
    // Simple schema
    const UserSchema = new mongoose.Schema({
      email: String,
      password: String,
      name: String,
      role: String,
      isActive: Boolean,
      isVerified: Boolean,
      isAdmin: Boolean,
      permissions: [String],
      skills: [String],
      picture: String,
      googleId: String,
      createdAt: Date,
      updatedAt: Date
    });

    const User = mongoose.model('User', UserSchema);
    
    const adminEmail = 'admin@devkazi.com';
    const adminPassword = 'Mal2092004';
    
    // Hash password
    const hashedPassword = await bcryptjs.hash(adminPassword, 12);
    
    // Delete if exists
    await User.deleteOne({ email: adminEmail });
    
    // Create new
    await User.create({
      email: adminEmail,
      password: hashedPassword,
      name: 'System Administrator',
      role: 'super_admin',
      isAdmin: true,
      isVerified: true,
      isActive: true,
      permissions: ['*'],
      skills: ['administration'],
      createdAt: new Date(),
      updatedAt: new Date()
    });
    
    console.log('✅ SUPER_ADMIN user created in TEST database!');
    console.log(`Email: ${adminEmail}`);
    console.log(`Password: ${adminPassword}`);
    console.log(`Role: super_admin`);
    console.log(`Database: test`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.disconnect();
  }
}

createAdmin();