import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    // Bind event listeners
    this.toggleMenu = this.toggleMenu.bind(this)
    this.close = this.close.bind(this)

    // Add event listeners
    const menuToggle = document.getElementById('menuToggle')

    if (menuToggle) {
      menuToggle.addEventListener('click', this.toggleMenu)
    }

    // Close sidebar on escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.close()
      }
    })
  }

  disconnect() {
    const menuToggle = document.getElementById('menuToggle')

    if (menuToggle) {
      menuToggle.removeEventListener('click', this.toggleMenu)
    }
  }

  toggleMenu() {
    const sidebar = document.getElementById('sidebar')

    if (sidebar) {
      sidebar.classList.toggle('active')
      document.body.classList.toggle('sidebar-open')
    }
  }

  close() {
    const sidebar = document.getElementById('sidebar')

    if (sidebar) {
      sidebar.classList.remove('active')
      document.body.classList.remove('sidebar-open')
    }
  }
}
