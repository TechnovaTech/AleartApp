'use client';

import { useState, useEffect } from 'react';

interface QRCode {
  _id: string;
  upiId: string;
  userId: string;
  qrData: string;
  createdAt: string;
}

export default function QRPage() {
  const [qrCodes, setQrCodes] = useState<QRCode[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  useEffect(() => {
    fetchQRCodes();
    const interval = setInterval(fetchQRCodes, 3000);
    return () => clearInterval(interval);
  }, []);

  const fetchQRCodes = async () => {
    try {
      const response = await fetch('/api/qr?userId=all');
      const data = await response.json();
      console.log('QR API Response:', data);
      if (data.qrCodes) {
        console.log('Setting QR codes:', data.qrCodes);
        setQrCodes(data.qrCodes);
      }
    } catch (error) {
      console.error('Failed to fetch QR codes:', error);
    }
  };

  const filteredQRs = qrCodes.filter(qr => {
    const matchesSearch = qr.upiId.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         qr.userId.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesSearch;
  });

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">QR Code Management</h1>
        <p className="text-gray-600">View and manage all generated QR codes and UPI IDs</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-medium text-gray-500">Total QR Codes</h3>
              <p className="text-2xl font-bold text-blue-600">{qrCodes.length}</p>
            </div>
            <svg className="h-8 w-8 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
          </div>
          <p className="text-xs text-blue-600 mt-1">All generated codes</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div>
            <h3 className="text-sm font-medium text-gray-500">Active QR Codes</h3>
            <p className="text-2xl font-bold text-green-600">{qrCodes.length}</p>
          </div>
          <p className="text-xs text-green-600 mt-1">Currently in use</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div>
            <h3 className="text-sm font-medium text-gray-500">Recent Activity</h3>
            <p className="text-2xl font-bold text-purple-600">Live</p>
          </div>
          <p className="text-xs text-purple-600 mt-1">Auto-refresh 3s</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow-sm border">
          <div>
            <h3 className="text-sm font-medium text-gray-500">Last Updated</h3>
            <p className="text-2xl font-bold text-yellow-600">{new Date().toLocaleTimeString()}</p>
          </div>
          <p className="text-xs text-yellow-600 mt-1">Real-time data</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm border mb-6">
        <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
          <div className="flex-1 relative">
            <svg className="absolute left-3 top-3 h-4 w-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <input
              type="text"
              placeholder="Search by user ID or UPI ID..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div className="flex gap-2">
            <button className="flex items-center px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
              <svg className="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
              Export
            </button>
          </div>
        </div>
      </div>

      {/* Debug Info */}
      <div className="mb-4 p-4 bg-yellow-50 border border-yellow-200 rounded">
        <p>Total QR Codes: {qrCodes.length}</p>
        <p>Filtered QR Codes: {filteredQRs.length}</p>
        <p>Search Term: '{searchTerm}'</p>
      </div>

      {/* QR Codes Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredQRs.map((qr) => (
          <div key={qr._id} className="bg-white rounded-lg shadow-sm border p-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center">
                <div className="h-10 w-10 bg-blue-500 rounded-full flex items-center justify-center">
                  <span className="text-white font-medium text-sm">
                    {qr.userId.charAt(0).toUpperCase()}
                  </span>
                </div>
                <div className="ml-3">
                  <h3 className="text-sm font-medium text-gray-900">{qr.userId}</h3>
                  <p className="text-xs text-gray-500">{qr.upiId}</p>
                </div>
              </div>
              <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                active
              </span>
            </div>

            {/* QR Code Visual */}
            <div className="bg-gray-50 p-4 rounded-lg mb-4 flex items-center justify-center">
              <div className="w-24 h-24 bg-white border-2 border-gray-300 rounded-lg flex items-center justify-center">
                <svg className="w-12 h-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div className="text-center">
                <p className="text-lg font-bold text-blue-600">New</p>
                <p className="text-xs text-gray-500">Status</p>
              </div>
              <div className="text-center">
                <p className="text-sm font-medium text-gray-900">{new Date(qr.createdAt).toLocaleDateString()}</p>
                <p className="text-xs text-gray-500">Created</p>
              </div>
            </div>

            {/* Actions */}
            <div className="flex justify-between items-center pt-4 border-t">
              <p className="text-xs text-gray-500">ID: {qr._id.slice(-6)}</p>
              <div className="flex space-x-2">
                <button className="text-blue-600 hover:text-blue-900">
                  <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                </button>
                <button className="text-green-600 hover:text-green-900">
                  <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                  </svg>
                </button>
                <button className="text-red-600 hover:text-red-900">
                  <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredQRs.length === 0 && (
        <div className="text-center py-12">
          <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          <h3 className="mt-2 text-sm font-medium text-gray-900">No QR codes</h3>
          <p className="mt-1 text-sm text-gray-500">QR codes will appear here when generated from the app.</p>
        </div>
      )}
    </div>
  );
}