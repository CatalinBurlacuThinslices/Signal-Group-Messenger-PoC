import { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

function App() {
  const [groups, setGroups] = useState([])
  const [selectedGroup, setSelectedGroup] = useState('')
  const [message, setMessage] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [apiStatus, setApiStatus] = useState({ backend: 'unknown', signalApi: 'unknown' })
  const [showLinkDevice, setShowLinkDevice] = useState(false)
  const [qrCodeUrl, setQrCodeUrl] = useState('')

  // Check API health on mount
  useEffect(() => {
    checkApiHealth()
    fetchGroups()
  }, [])

  const checkApiHealth = async () => {
    try {
      const response = await axios.get('/api/health')
      setApiStatus({
        backend: response.data.backend,
        signalApi: response.data.signalApi?.status === 'ok' ? 'connected' : 'error'
      })
    } catch (err) {
      console.error('Health check failed:', err)
      setApiStatus({
        backend: 'running',
        signalApi: 'unreachable'
      })
    }
  }

  const fetchGroups = async () => {
    setLoading(true)
    setError('')
    
    try {
      console.log('Fetching groups...')
      const response = await axios.get('/api/groups')
      
      console.log('Groups response:', response.data)
      
      if (response.data.success) {
        setGroups(response.data.groups)
        if (response.data.groups.length === 0) {
          setError('No groups found. Create a group in Signal first.')
        }
      } else {
        setError(response.data.error || 'Failed to fetch groups')
      }
    } catch (err) {
      console.error('Error fetching groups:', err)
      const errorMsg = err.response?.data?.error || err.message || 'Failed to fetch groups'
      const hint = err.response?.data?.hint || ''
      setError(`${errorMsg}${hint ? '. ' + hint : ''}`)
      
      // Log full error for debugging
      if (err.response?.data?.details) {
        console.error('Error details:', err.response.data.details)
      }
    } finally {
      setLoading(false)
    }
  }

  const handleSendMessage = async (e) => {
    e.preventDefault()
    
    // Clear previous messages
    setError('')
    setSuccess('')

    // Validation
    if (!selectedGroup) {
      setError('Please select a group')
      return
    }

    if (!message.trim()) {
      setError('Please enter a message')
      return
    }

    setLoading(true)

    try {
      console.log('Sending message to group:', selectedGroup)
      console.log('Message:', message)

      const response = await axios.post('/api/send', {
        groupId: selectedGroup,
        message: message.trim()
      })

      console.log('Send response:', response.data)

      if (response.data.success) {
        setSuccess('✅ Message sent successfully!')
        setMessage('') // Clear message input
        
        // Clear success message after 5 seconds
        setTimeout(() => setSuccess(''), 5000)
      } else {
        setError(response.data.error || 'Failed to send message')
      }

    } catch (err) {
      console.error('Error sending message:', err)
      
      const errorMsg = err.response?.data?.error || err.message || 'Failed to send message'
      const details = err.response?.data?.details || ''
      const hint = err.response?.data?.hint || ''
      
      let fullError = errorMsg
      if (details) fullError += `\nDetails: ${details}`
      if (hint) fullError += `\nHint: ${hint}`
      
      setError(fullError)
      
      // Log full error for debugging
      console.error('Full error:', err.response?.data)
    } finally {
      setLoading(false)
    }
  }

  const getSelectedGroupName = () => {
    const group = groups.find(g => g.id === selectedGroup)
    return group ? group.name : ''
  }

  const handleLinkDevice = async () => {
    setShowLinkDevice(true)
    setError('')
    
    try {
      console.log('Generating QR code...')
      
      // Generate QR code URL with timestamp to prevent caching
      const timestamp = new Date().getTime()
      const qrUrl = `/api/link-device?deviceName=SignalPoC&t=${timestamp}`
      setQrCodeUrl(qrUrl)
      
    } catch (err) {
      console.error('Error generating QR code:', err)
      setError('Failed to generate QR code. Make sure Signal API is running.')
      setShowLinkDevice(false)
    }
  }

  const closeLinkDevice = () => {
    setShowLinkDevice(false)
    setQrCodeUrl('')
  }

  return (
    <div className="app">
      <header className="header">
        <h1>📱 Signal Group Messenger</h1>
        <p className="subtitle">Send messages to Signal groups</p>
        
        <div className="status-bar">
          <span className={`status-badge ${apiStatus.backend === 'running' ? 'online' : 'offline'}`}>
            Backend: {apiStatus.backend}
          </span>
          <span className={`status-badge ${apiStatus.signalApi === 'connected' ? 'online' : 'offline'}`}>
            Signal API: {apiStatus.signalApi}
          </span>
          <button onClick={handleLinkDevice} className="btn-link-device">
            📱 Link Device
          </button>
        </div>
      </header>

      <main className="main-content">
        <div className="container">
          
          {/* Groups Section */}
          <div className="card">
            <div className="card-header">
              <h2>Your Groups</h2>
              <button 
                onClick={fetchGroups} 
                disabled={loading}
                className="btn-secondary"
              >
                🔄 Refresh
              </button>
            </div>
            
            {groups.length > 0 ? (
              <div className="groups-list">
                {groups.map((group) => (
                  <div 
                    key={group.id}
                    className={`group-item ${selectedGroup === group.id ? 'selected' : ''}`}
                    onClick={() => setSelectedGroup(group.id)}
                  >
                    <div className="group-info">
                      <span className="group-name">{group.name}</span>
                      <span className="group-members">{group.memberCount} members</span>
                    </div>
                    {group.isAdmin && <span className="admin-badge">Admin</span>}
                  </div>
                ))}
              </div>
            ) : (
              <div className="empty-state">
                {loading ? (
                  <p>Loading groups...</p>
                ) : (
                  <p>No groups found. Create a group in Signal app first.</p>
                )}
              </div>
            )}
          </div>

          {/* Message Form */}
          <div className="card">
            <h2>Send Message</h2>
            
            <form onSubmit={handleSendMessage}>
              <div className="form-group">
                <label htmlFor="group-select">Select Group:</label>
                <select
                  id="group-select"
                  value={selectedGroup}
                  onChange={(e) => setSelectedGroup(e.target.value)}
                  disabled={loading || groups.length === 0}
                  className="form-control"
                >
                  <option value="">-- Choose a group --</option>
                  {groups.map((group) => (
                    <option key={group.id} value={group.id}>
                      {group.name} ({group.memberCount} members)
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="message-input">Message:</label>
                <textarea
                  id="message-input"
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  placeholder="Type your message here..."
                  rows="6"
                  disabled={loading || !selectedGroup}
                  className="form-control"
                />
                <div className="char-count">
                  {message.length} characters
                </div>
              </div>

              {selectedGroup && (
                <div className="selected-group-info">
                  Sending to: <strong>{getSelectedGroupName()}</strong>
                </div>
              )}

              <button 
                type="submit" 
                disabled={loading || !selectedGroup || !message.trim()}
                className="btn-primary"
              >
                {loading ? '⏳ Sending...' : '📤 Send Message'}
              </button>
            </form>
          </div>

          {/* Error Messages */}
          {error && (
            <div className="alert alert-error">
              <strong>❌ Error:</strong>
              <pre>{error}</pre>
            </div>
          )}

          {/* Success Messages */}
          {success && (
            <div className="alert alert-success">
              {success}
            </div>
          )}

          {/* Link Device Modal */}
          {showLinkDevice && (
            <div className="modal-overlay" onClick={closeLinkDevice}>
              <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <div className="modal-header">
                  <h2>📱 Link Your Signal Account</h2>
                  <button onClick={closeLinkDevice} className="modal-close">✕</button>
                </div>
                
                <div className="modal-body">
                  <div className="qr-container">
                    {qrCodeUrl ? (
                      <>
                        <img src={qrCodeUrl} alt="QR Code" className="qr-code" />
                        <p className="qr-instructions">
                          <strong>Scan this QR code with your phone:</strong>
                        </p>
                        <ol className="qr-steps">
                          <li>Open Signal app on your phone</li>
                          <li>Go to Settings → Linked Devices</li>
                          <li>Tap "+" or "Link New Device"</li>
                          <li>Scan this QR code</li>
                          <li>Confirm on your phone</li>
                        </ol>
                        <p className="qr-note">
                          ⏱️ QR code expires in 60 seconds. Click "Regenerate" if needed.
                        </p>
                        <button onClick={handleLinkDevice} className="btn-secondary">
                          🔄 Regenerate QR Code
                        </button>
                      </>
                    ) : (
                      <p>Generating QR code...</p>
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}

        </div>
      </main>

      <footer className="footer">
        <p>Signal Group Messenger PoC - Built with React + Node.js</p>
        <p className="footer-note">
          Requires <a href="https://github.com/bbernhard/signal-cli-rest-api" target="_blank" rel="noopener noreferrer">
            signal-cli-rest-api
          </a> running
        </p>
      </footer>
    </div>
  )
}

export default App

