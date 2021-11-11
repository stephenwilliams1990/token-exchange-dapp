
import React, { Component } from 'react' 
import { connect } from 'react-redux'
import { accountSelector } from '../store/selectors'

class Navbar extends Component {
    render() {
        return (
            <nav className="navbar navbar-expand-lg navbar-dark bg-primary">
                <div className="container">
                    <a className="navbar-brand" href="/#">Medallo Token Exchange</a>
                    <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
                    <span className="navbar-toggler-icon"></span>
                    </button>
                    <ul className="navbar-nav ml-auto">
                        <li className="nav-item">
                            <a 
                                className="nav-link small"
                                href={`https://etherscan.io/address/${this.props.account}`} // react uses these curly braces to allow us to evaluate javascript code within HTML
                                target="_blank"
                                rel="noopener noreferrer"
                            >
                                {this.props.account} 
                            </a>
                        </li>
                        <li className="nav-item"> 
                            <span className="navbar-brand">Run on Goerli Test Network</span>
                        </li>
                    </ul>
                </div>
            </nav>
        )
    }   
}

function mapStateToProps(state) {
    return {
      account: accountSelector(state)
    }
  }

export default connect(mapStateToProps)(Navbar)