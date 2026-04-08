import unittest
from app import app

class VoteAppTestCase(unittest.TestCase):

    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_home_page_loads(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)

    def test_home_page_contains_options(self):
        response = self.app.get('/')
        self.assertIn(b'Cats', response.data)
        self.assertIn(b'Dogs', response.data)

    def test_metrics_endpoint(self):
        response = self.app.get('/metrics')
        self.assertEqual(response.status_code, 200)

    def test_vote_post(self):
        response = self.app.post('/', data={'vote': 'a'})
        self.assertEqual(response.status_code, 200)

if __name__ == '__main__':
    unittest.main()