'use client';

import { useState, useEffect } from 'react';
import QRCode from 'qrcode';

interface User {
  _id: string;
  username: string;
  email: string;
  qrCount: number;
}

interface QRCode {
  _id: string;
  upiId: string;
  userId: string;
  qrData: string;
  createdAt: string;
}

function QRDisplay({ qrData }: { qrData: string }) {
  const [qrImage, setQrImage] = useState<string>('');
  
  useEffect(() => {
    const generateQR = async () => {
      try {
        const qrDataURL = await QRCode.toDataURL(qrData, {
          width: 128,
          margin: 1,
        });
        setQrImage(qrDataURL);
      } catch (error) {
        console.error('Error generating QR code:', error);
      }
    };
    generateQR();
  }, [qrData]);
  
  return (
    <div className="bg-gray-50 p-6 rounded flex items-center justify-center">
      {qrImage ? (
        <img src={qrImage} alt="QR Code" className="w-48 h-48" />
      ) : (
        <div className="w-48 h-48 bg-white border rounded flex items-center justify-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
        </div>
      )}
    </div>
  );
}

export default function QRPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [userQRs, setUserQRs] = useState<QRCode[]>([]);
  const [showModal, setShowModal] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const response = await fetch('/api/users');
      const data = await response.json();
      if (data.users) {
        setUsers(data.users);
      }
    } catch (error) {
      console.error('Failed to fetch users:', error);
    }
  };

  const fetchUserQRs = async (userId: string) => {
    try {
      const response = await fetch(`/api/qr?userId=${userId}`);
      const data = await response.json();
      if (data.qrCodes) {
        setUserQRs(data.qrCodes);
      }
    } catch (error) {
      console.error('Failed to fetch user QRs:', error);
    }
  };

  const handleViewQRs = async (user: User) => {
    setSelectedUser(user);
    await fetchUserQRs(user._id);
    setShowModal(true);
  };

  const filteredUsers = users.filter(user => 
    user.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">User QR Management</h1>
        <p className="text-gray-600">View users and their QR codes</p>
      </div>

      {/* Search */}
      <div className="bg-white p-4 rounded-lg shadow-sm border mb-6">
        <div className="relative">
          <svg className="absolute left-3 top-3 h-4 w-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input
            type="text"
            placeholder="Search by username or email..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">QR Count</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {filteredUsers.map((user) => (
              <tr key={user._id}>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center">
                    <div className="h-10 w-10 bg-blue-500 rounded-full flex items-center justify-center">
                      <span className="text-white font-medium text-sm">
                        {user.username.charAt(0).toUpperCase()}
                      </span>
                    </div>
                    <div className="ml-4">
                      <div className="text-sm font-medium text-gray-900">{user.username}</div>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{user.email}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                    {user.qrCount}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button
                    onClick={() => handleViewQRs(user)}
                    className="text-blue-600 hover:text-blue-900"
                  >
                    View QRs
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* QR Modal */}
      {showModal && selectedUser && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
          <div className="p-6 border w-5/6 max-w-5xl shadow-lg rounded-md bg-white max-h-[90vh] overflow-y-auto">
            <div className="mt-3">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-medium text-gray-900">
                  {selectedUser.username}'s QR Codes
                </h3>
                <button
                  onClick={() => setShowModal(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {userQRs.map((qr) => (
                  <div key={qr._id} className="border rounded-lg p-4">
                    <div className="text-sm font-medium text-gray-900 mb-2">{qr.upiId}</div>
                    <QRDisplay qrData={qr.qrData} />
                    <div className="text-xs text-gray-500 mt-2">
                      Created: {new Date(qr.createdAt).toLocaleDateString()}
                    </div>
                  </div>
                ))}
                
                {userQRs.length === 0 && (
                  <div className="col-span-2 text-center py-8 text-gray-500">
                    No QR codes found for this user
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}