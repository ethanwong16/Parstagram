//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Ethan Wong on 5/5/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject! // to remember the current post
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self      // any time "post" is pressed, delegates to self
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        /* message input bars work with table view natively! */
        tableView.keyboardDismissMode = .interactive // can dismiss keyboard by dragging down
        
        /* hacks to make keyboard disappear using NotificationCenter & setting observer function */
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(node:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(node: Notification) {
        // clear text field
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    /* these functions are "intermediate iOS - "hacking" original framework */
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    // ----------------------------
    
    /* for refreshing */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /* query to get posts */
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground(block: { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        })
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()

        selectedPost.add(comment, forKey: "comments")

        // Parse is smart, realizes comment needs to be saved when you save the post
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        // refresh table view to reflect updated stuff
        tableView.reloadData() // could also do animations with this!
        
        // clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? [] // if it's nil it has default value of empty arr
        
        return comments.count + 2 // one for post, one for add comment
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 { // the first one is always a post cell, and after it's followed by comments
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostTableViewCell
            
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            /* display image */
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count { // comments in between 0th = post and last one = add comment
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
            
            let comment = comments[indexPath.row - 1] // since first one is the post
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
        
    }
    
    // table views support selection by default (will call here everytime user taps)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section] // so you link comments to correct row / post index
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder() // cause canBecomeFirstResponder to be evaluated again
            commentBar.inputTextView.becomeFirstResponder() // raise keyboard
            
            selectedPost = post // remember post for later
        }
        
        /* fake comment stuff */
//        comment["text"] = "This is a random comment"
//        comment["post"] = post
//        comment["author"] = PFUser.current()
//
//        post.add(comment, forKey: "comments")
//
//        // Parse is smart, realizes comment needs to be saved when you save the post
//        post.saveInBackground { (success, error) in
//            if success {
//                print("Comment saved")
//            } else {
//                print("Error saving comment")
//            }
//        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut(); // clears Parse's cache so we're not recorded as logout
        
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        
        // access window to update current view upon logout
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
    }
}
