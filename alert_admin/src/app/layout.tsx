'use client'

import './globals.css'
import DashboardLayout from '@/components/DashboardLayout'
import { usePathname } from 'next/navigation'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const pathname = usePathname()
  const isLoginPage = pathname === '/'

  return (
    <html lang="en">
      <body>
        {isLoginPage ? children : <DashboardLayout>{children}</DashboardLayout>}
      </body>
    </html>
  )
}