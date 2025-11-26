import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:3001/api', // Adjust the baseURL to your backend API
});

export const setAuthToken = (token: string | null) => {
  if (token) {
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  } else {
    delete api.defaults.headers.common['Authorization'];
  }
};

export default api;
