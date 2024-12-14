import { Outlet } from "react-router-dom";
import { Toaster } from "@/components/ui/toaster";

const HomeLayout = () => {
  return (
    <div className="body">
      <main>
        <Outlet />
        <Toaster />
      </main>
    </div>
  );
};

export default HomeLayout;
