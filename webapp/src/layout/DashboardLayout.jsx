import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar";
import { AppSidebar } from "@/layout/AppSidebar";
import { Outlet } from "react-router-dom";

export default function DashboardLayout() {
  return (
    <SidebarProvider>
      <AppSidebar />
      <div className="dashboard-container flex-grow">
        <SidebarTrigger />
        <Outlet />
      </div>
    </SidebarProvider>
  );
}
