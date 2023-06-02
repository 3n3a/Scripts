package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	// mobileconfig "github.com/ProtonMail/go-apple-mobileconfig"
	mobileconfig "github.com/ProtonMail/go-apple-mobileconfig"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

var (
	focusedStyle        = lipgloss.NewStyle().Foreground(lipgloss.Color("205"))
	blurredStyle        = lipgloss.NewStyle().Foreground(lipgloss.Color("240"))
	cursorStyle         = focusedStyle.Copy()
	noStyle             = lipgloss.NewStyle()
	helpStyle           = blurredStyle.Copy()
	cursorModeHelpStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("244"))

	focusedButton = focusedStyle.Copy().Render("[ Submit ]")
	blurredButton = fmt.Sprintf("[ %s ]", blurredStyle.Render("Submit"))
)

type model struct {
	focusIndex int
	inputs     []textinput.Model
	cursorMode textinput.CursorMode
}

func initialModel() model {
	m := model{
		inputs: make([]textinput.Model, 10),
	}

	var t textinput.Model
	for i := range m.inputs {
		t = textinput.New()
		t.Cursor.Style = cursorStyle
		t.CharLimit = 32

		switch i {
		case 0:
			t.Prompt = "Configuration Name: "
			t.Placeholder = "What should your Configuration be called?"
			t.Focus()
			t.PromptStyle = focusedStyle
			t.TextStyle = focusedStyle
		case 1:
			t.Prompt = "Email: "
			t.Placeholder = "Your Email Address (hello@example.com)"
			t.PromptStyle = focusedStyle
			t.TextStyle = focusedStyle
		case 2:
			t.Prompt = "Identifier: "
			t.Placeholder = "Profile Identifiert (com.example.mail)"
			t.PromptStyle = focusedStyle
			t.TextStyle = focusedStyle
		case 3:
			t.Prompt = "Incoming Mail Server: "
			t.Placeholder = "Address of incoming Mail Server (mail.example.com)"
			t.PromptStyle = focusedStyle
			t.TextStyle = focusedStyle
		case 4:
			t.Prompt = "Incoming Mail Port: "
			t.Placeholder = "Port of Mail Server"
			t.PromptStyle = focusedStyle
			t.TextStyle = focusedStyle
		case 5:
			t.Prompt = "Outgoing Mail Server: "
			t.Placeholder = "Address of outgoing Mail Server (mail.example.com)"
			t.PromptStyle = focusedStyle
			t.TextStyle = focusedStyle
		case 6:
			t.Prompt = "Outgoing Mail Port: "
			t.Placeholder = "Port of Mail Server"
			t.PromptStyle = focusedStyle
			t.TextStyle = focusedStyle
		case 7:
			t.Prompt = "Mail Server Username: "
			t.Placeholder = "Username for your Mail Server (Email)"
			t.PromptStyle = focusedStyle
			t.TextStyle = focusedStyle
		case 8:
			t.Prompt = "Mail Server Password: "
			t.EchoMode = textinput.EchoPassword
			t.EchoCharacter = '•'
		case 9:
			t.Prompt = "Filename of Configuration: "
			t.Placeholder = "Generating filename..."
			t.CharLimit = 128
			t.PromptStyle = focusedStyle
			t.TextStyle = focusedStyle
		}

		m.inputs[i] = t
	}

	return m
}

func (m model) Init() tea.Cmd {
	return textinput.Blink
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "esc":
			return m, tea.Quit

		// Change cursor mode
		case "ctrl+r":
			m.cursorMode++
			if m.cursorMode > textinput.CursorHide {
				m.cursorMode = textinput.CursorBlink
			}
			cmds := make([]tea.Cmd, len(m.inputs))
			for i := range m.inputs {
				cmds[i] = m.inputs[i].SetCursorMode(m.cursorMode)
			}
			return m, tea.Batch(cmds...)

		// Set focus to next input
		case "tab", "shift+tab", "enter", "up", "down":
			s := msg.String()

			// Did the user press enter while the submit button was focused?
			// If so, exit.
			if s == "enter" && m.focusIndex == len(m.inputs) {
				// create profile and then exit
				createIOSProfile(m)
				return m, tea.Quit
			}

			// Cycle indexes
			if s == "up" || s == "shift+tab" {
				m.focusIndex--
			} else {
				m.focusIndex++
			}

			if m.focusIndex > len(m.inputs) {
				m.focusIndex = 0
			} else if m.focusIndex < 0 {
				m.focusIndex = len(m.inputs)
			}

			cmds := make([]tea.Cmd, len(m.inputs))
			for i := 0; i <= len(m.inputs)-1; i++ {
				if i == m.focusIndex {
					// Set focused state
					cmds[i] = m.inputs[i].Focus()
					m.inputs[i].PromptStyle = focusedStyle
					m.inputs[i].TextStyle = focusedStyle
					continue
				}

				if (len(m.inputs[2].Value()) > 0){
					m.inputs[9].SetValue(fmt.Sprintf("%s.mobileconfig", m.inputs[2].Value()))
				} else{
					m.inputs[9].Placeholder = "Generating filename..."
				} 

				// Remove focused state
				m.inputs[i].Blur()
				m.inputs[i].PromptStyle = noStyle
				m.inputs[i].TextStyle = noStyle
			}

			return m, tea.Batch(cmds...)
		}
	}

	// Handle character input and blinking
	cmd := m.updateInputs(msg)

	return m, cmd
}

func (m *model) updateInputs(msg tea.Msg) tea.Cmd {
	cmds := make([]tea.Cmd, len(m.inputs))

	// Only text inputs with Focus() set will respond, so it's safe to simply
	// update all of them here without any further logic.
	for i := range m.inputs {
		m.inputs[i], cmds[i] = m.inputs[i].Update(msg)
	}

	return tea.Batch(cmds...)
}

func (m model) View() string {
	var b strings.Builder

	for i := range m.inputs {
		b.WriteString(m.inputs[i].View())
		if i < len(m.inputs)-1 {
			b.WriteRune('\n')
		}
	}

	button := &blurredButton
	if m.focusIndex == len(m.inputs) {
		button = &focusedButton
	}
	fmt.Fprintf(&b, "\n\n%s\n\n", *button)

	b.WriteString(helpStyle.Render("cursor mode is "))
	b.WriteString(cursorModeHelpStyle.Render(m.cursorMode.String()))
	b.WriteString(helpStyle.Render(" (ctrl+r to change style)"))

	return b.String()
}

func main() {
	if _, err := tea.NewProgram(initialModel()).Run(); err != nil {
		fmt.Printf("could not start program: %s\n", err)
		os.Exit(1)
	}
}

func createIOSProfile(m model) {
	incomingPort, _ := strconv.Atoi(m.inputs[5].Value())
	outgoingPort, _ := strconv.Atoi(m.inputs[6].Value())
	c := &mobileconfig.Config{
		DisplayName: m.inputs[0].Value(),
		EmailAddress: m.inputs[1].Value(),
		Identifier: m.inputs[2].Value(),
		Organization: m.inputs[3].Value(),
		Imap: &mobileconfig.Imap{
			Hostname: m.inputs[4].Value(),
			Port: incomingPort,
			Tls: true,
			Username: m.inputs[7].Value(),
			Password: m.inputs[8].Value(),
		},
		Smtp: &mobileconfig.Smtp{
			Hostname: m.inputs[5].Value(),
			Port: outgoingPort,
			Tls: false,
			Username: m.inputs[7].Value(),
			Password: m.inputs[8].Value(),
		},
	}

	filename := m.inputs[9].Value()

	f, err := os.Create(filename)
	if err != nil {
		panic(err)
	}
	if err := c.WriteTo(f); err != nil {
		panic(err)
	}
	fmt.Println("File saved to %s", filename)
}