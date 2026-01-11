import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ToastProvider } from './contexts/ToastContext';
import MainLayout from './components/layout/MainLayout';
import VenueList from './pages/VenueList';
import VenueCreate from './pages/VenueCreate';
import VenueEdit from './pages/VenueEdit';
import LandingPage from './pages/LandingPage';

function App() {
  return (
    <ToastProvider>
      <BrowserRouter>
        <Routes>
          {/* Public Route */}
          <Route path="/" element={<LandingPage />} />

          {/* Admin Routes with MainLayout */}
          <Route path="/admin/*" element={
            <MainLayout>
              <Routes>
                <Route index element={<Navigate to="venues" replace />} />
                <Route path="venues" element={<VenueList />} />
                <Route path="venues/create" element={<VenueCreate />} />
                <Route path="venues/:id/edit" element={<VenueEdit />} />
                <Route path="*" element={<Navigate to="venues" replace />} />
              </Routes>
            </MainLayout>
          } />

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </ToastProvider>
  );
}

export default App;
