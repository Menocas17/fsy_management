module NavigationHelper
  def nav_items
    [
      { text: "Inicio", url: dashboard_path, icon: "home.svg", secondary_icon: "home-s.svg" },
      { text: "Jóvenes", url: participants_path, icon: "nav-people.svg", secondary_icon: "nav-people-s.svg", section: "jovenes" },
      { text: "Staff", url: staff_participants_path, icon: "nav-people.svg", secondary_icon: "nav-people-s.svg", section: "staff" },
      { text: "Compañías", url: companies_path, icon: "company.svg", secondary_icon: "company.svg", section: "companies" },
      { text: "Mi perfil", url: myprofile_participants_path, icon: "profile.svg", secondary_icon: "profile-s.svg", section: "myprofile" }
    ].map { |item| item.merge(is_nav: true) }
  end
end
