import "./App.css";
import {
  createBrowserRouter,
  createRoutesFromElements,
  Route,
  RouterProvider,
} from "react-router-dom";
import React from "react";
import LoginPage from "./pages/Login";
import RegisrationPage from "./pages/Registration";
import DashboardLayout from "./layout/DashboardLayout";
import HomeLayout from "./layout/HomeLayout";
import ProtectedLayout from "./layout/ProtectedLayout";
import AuthRouter from "./pages/AuthRouter";

const router = createBrowserRouter(
  createRoutesFromElements(
    <>
      <Route element={<ProtectedLayout />}>
        <Route element={<DashboardLayout />}></Route>
      </Route>

      <Route element={<HomeLayout />}>
        <Route path="/" element={<AuthRouter />} />
        <Route path="/register" element={<RegisrationPage />} />
        <Route path="/login" element={<LoginPage />} />
      </Route>
    </>
  ),
  {
    basename: "/",
    future: {
      v7_skipActionErrorRevalidation: true,
      v7_normalizeFormMethod: true,
      v7_relativeSplatPath: true,
      v7_fetcherPersist: true,
      v7_partialHydration: true,
      v7_startTransition: true,
    },
  }
);

function App() {
  return (
    <React.StrictMode>
      <RouterProvider router={router} />
    </React.StrictMode>
  );
}

export default App;
