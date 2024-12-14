import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupLabel,
  SidebarGroupContent,
  SidebarHeader,
  SidebarMenuItem,
  SidebarMenuButton,
  SidebarMenu,
} from "@/components/ui/sidebar";
import {
  Contact,
  Calendar,
  Home,
  Inbox,
  Search,
  Settings,
  LogOut,
  Users,
  Plus,
  BotMessageSquare,
  MessageSquareHeart,
  ChartBar,
  Building2,
  CircleCheckBig,
  Zap,
  Key,
} from "lucide-react";
import { Link } from "react-router-dom";
import { LogoutButton } from "@/components/LogoutButton";

const agents = [
  {
    title: "Dashboard",
    url: "/dashboard",
    icon: Home,
  },
  {
    title: "Hiring by Chat",
    url: "/agents/create-with-ai",
    icon: BotMessageSquare,
  },
  {
    title: "AI Employees",
    url: "/agents",
    icon: Users,
  },
  {
    title: "Tasks",
    url: "/tasks",
    icon: CircleCheckBig,
  },
  {
    title: "Triggers",
    url: "/triggers",
    icon: Zap,
  },
  {
    title: "API Keys",
    url: "/api-keys",
    icon: Key,
  },
  {
    title: "Call History",
    url: "/conversations",
    icon: MessageSquareHeart,
  },
];

const profiles = [
  {
    title: "Customers",
    url: "/customers",
    icon: Contact,
  },
  {
    title: "Company Profile",
    url: "/profile",
    icon: Building2,
  },
];

const SidebarMenuGroup = ({ title, items }) => {
  return (
    <SidebarGroup>
      <SidebarGroupLabel>{title}</SidebarGroupLabel>
      <SidebarGroupContent>
        <SidebarMenu>
          {items.map((item) => (
            <SidebarMenuItem key={item.title}>
              <SidebarMenuButton asChild>
                <Link to={item.url}>
                  <item.icon />
                  <span>{item.title}</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
          ))}
        </SidebarMenu>
      </SidebarGroupContent>
    </SidebarGroup>
  );
};

export function AppSidebar() {
  return (
    <Sidebar>
      <SidebarHeader />
      <SidebarContent>
        <SidebarMenuGroup title="Agents" items={agents} />
        <SidebarMenuGroup title="Profiles" items={profiles} />
      </SidebarContent>
      <SidebarFooter>
        <SidebarMenu>
          <SidebarMenuItem key="logout">
            <SidebarMenuButton asChild>
              <LogoutButton>
                <LogOut />
                <span>Logout</span>
              </LogoutButton>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  );
}
