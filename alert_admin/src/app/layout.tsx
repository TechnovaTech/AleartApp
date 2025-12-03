import './globals.css'
import DashboardLayout from '@/components/DashboardLayout'

export const metadata = {
  title: 'AlertPe Admin Panel',
  description: 'Admin panel for AlertPe Soundbox',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <DashboardLayout>{children}</DashboardLayout>
      </body>
    </html>
  )
}