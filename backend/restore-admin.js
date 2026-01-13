const mongoose = require('mongoose');
const bcryptjs = require('bcryptjs');

async function restoreSuperAdmin() {
  console.log('🚀 RESTORING SUPER_ADMIN USER...');
  
  // ⚠️ YOUR MONGODB ATLAS CONNECTION STRING
  const mongoUri = 'mongodb+srv://makutualvine_db_user:lFFomf9pWKI8jJwU@cluster0.slqqzms.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
  
  try {
    console.log('🔗 Connecting to MongoDB Atlas...');
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB Atlas');
    
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
      createdAt: Date,
      updatedAt: Date
    });

    const UserModel = mongoose.model('User', UserSchema);
    
    const adminEmail = 'admin@devkazi.com';
    const adminPassword = 'Mal2092004';
    const adminName = 'System Administrator';
    
    // Hash the password
    console.log('🔑 Hashing password...');
    const hashedPassword = await bcryptjs.hash(adminPassword, 12);
    console.log('✅ Password hashed');
    
    // Delete if exists
    await UserModel.deleteOne({ email: adminEmail });
    console.log('🗑️ Cleared old user (if any)');
    
    // Create new super_admin user
    const newAdmin = new UserModel({
      email: adminEmail,
      password: hashedPassword,
      name: adminName,
      role: 'super_admin',
      isAdmin: true,
      isVerified: true,
      isActive: true,
      permissions: ['*'],
      skills: ['administration', 'management'],
      createdAt: new Date(),
      updatedAt: new Date()
    });
    
    await newAdmin.save();
    console.log('✅ New SUPER_ADMIN user created!');
    
    console.log('\n🎉 SUPER_ADMIN RESTORATION COMPLETE!');
    console.log('📋 Admin Details:');
    console.log(`   Email: ${adminEmail}`);
    console.log(`   Password: ${adminPassword}`);
    console.log(`   Name: ${adminName}`);
    console.log(`   Role: super_admin`);
    
    console.log('\n💡 Now login at: http://localhost:3000/login');
    
  } catch (error) {
    console.error('\n❌ ERROR:', error.message);
    console.error('\n🔧 Make sure:');
    console.error('   1. Your MongoDB Atlas connection string is correct');
    console.error('   2. Your IP is whitelisted in MongoDB Atlas');
    console.error('   3. You can connect to the database');
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run it
restoreSuperAdmin();
